package installer

import (
	"fmt"
	"github.com/google/uuid"
	cp "github.com/otiai10/copy"
	"github.com/syncloud/golib/config"
	"github.com/syncloud/golib/linux"
	"github.com/syncloud/golib/platform"
	"go.uber.org/zap"
	"os"
	"os/exec"
	"path"
	"strings"
)

const App = "jitsimeet"

type Variables struct {
	App            string
	AppDir         string
	DataDir        string
	CommonDir      string
	AppUrl         string
	Domain         string
	AuthDomain     string
	JicofoPassword string
}

type Installer struct {
	newVersionFile     string
	currentVersionFile string
	configDir          string
	platformClient     *platform.Client
	installFile        string
	appDir             string
	dataDir            string
	commonDir          string
	prosodyCtl         string
	jicofoPasswordFile string
	logger             *zap.Logger
}

func New(logger *zap.Logger) *Installer {
	appDir := fmt.Sprintf("/snap/%s/current", App)
	dataDir := fmt.Sprintf("/var/snap/%s/current", App)
	commonDir := fmt.Sprintf("/var/snap/%s/common", App)
	prosodyCtl := path.Join(appDir, "prosody/bin/prosodyctl.sh")
	configDir := path.Join(dataDir, "config")
	jicofoPasswordFile := path.Join(dataDir, "jicofo.password")
	return &Installer{
		newVersionFile:     path.Join(appDir, "version"),
		currentVersionFile: path.Join(dataDir, "version"),
		configDir:          configDir,
		platformClient:     platform.New(),
		installFile:        path.Join(dataDir, "installed"),
		appDir:             appDir,
		dataDir:            dataDir,
		commonDir:          commonDir,
		prosodyCtl:         prosodyCtl,
		jicofoPasswordFile: jicofoPasswordFile,
		logger:             logger,
	}
}

func (i *Installer) Install() error {
	err := linux.CreateUser(App)
	if err != nil {
		return err
	}

	err = i.UpdateConfigs()
	if err != nil {
		return err
	}

	err = i.FixPermissions()
	if err != nil {
		return err
	}

	err = i.StorageChange()
	if err != nil {
		return err
	}
	return nil
}

func (i *Installer) Configure() error {
	if i.IsInstalled() {
		err := i.Upgrade()
		if err != nil {
			return err
		}
	} else {
		err := i.Initialize()
		if err != nil {
			return err
		}
	}

	return i.UpdateVersion()
}

func (i *Installer) Initialize() error {
	err := i.StorageChange()
	if err != nil {
		return err
	}

	domain, err := i.platformClient.GetAppDomainName(App)
	if err != nil {
		return err
	}

	authDomain := AuthDomain(domain)
	jicofoPassword, err := getOrCreateUuid(i.jicofoPasswordFile)
	if err != nil {
		return err
	}

	command := exec.Command(i.prosodyCtl, "register", "focus", authDomain, jicofoPassword)
	output, err := command.CombinedOutput()
	i.logger.Info("output", zap.String("cmd", strings.Replace(command.String(), jicofoPassword, "***", -1)), zap.String("output", string(output)))
	if err != nil {
		return err
	}

	//prosodyctl --config $PROSODY_CFG mod_roster_command subscribe focus.$XMPP_DOMAIN focus@$XMPP_AUTH_DOMAIN
	//prosodyctl --config $PROSODY_CFG register $JVB_AUTH_USER $XMPP_AUTH_DOMAIN $JVB_AUTH_PASSWORD
	//prosodyctl --config $PROSODY_CFG register $JIBRI_XMPP_USER $XMPP_AUTH_DOMAIN $JIBRI_XMPP_PASSWORD
	//prosodyctl --config $PROSODY_CFG register $JIBRI_RECORDER_USER $XMPP_RECORDER_DOMAIN $JIBRI_RECORDER_PASSWORD
	//prosodyctl --config $PROSODY_CFG register $JIGASI_XMPP_USER $XMPP_AUTH_DOMAIN $JIGASI_XMPP_PASSWORD
	//echo | prosodyctl --config $PROSODY_CFG cert generate $XMPP_DOMAIN
	//echo | prosodyctl --config $PROSODY_CFG cert generate $XMPP_AUTH_DOMAIN

	err = os.WriteFile(i.installFile, []byte("installed"), 0644)
	if err != nil {
		return err
	}

	return nil
}

func (i *Installer) Upgrade() error {
	err := i.StorageChange()
	if err != nil {
		return err
	}

	return nil
}

func (i *Installer) IsInstalled() bool {
	_, err := os.Stat(i.installFile)
	return err == nil
}

func (i *Installer) PreRefresh() error {
	return nil
}

func (i *Installer) PostRefresh() error {
	err := i.UpdateConfigs()
	if err != nil {
		return err
	}

	err = i.ClearVersion()
	if err != nil {
		return err
	}

	err = i.FixPermissions()
	if err != nil {
		return err
	}
	return nil
}

func (i *Installer) StorageChange() error {
	storageDir, err := i.platformClient.InitStorage(App, App)
	if err != nil {
		return err
	}

	err = linux.CreateMissingDirs(
		path.Join(i.dataDir, "nginx"),
		path.Join(i.dataDir, "data"),
		path.Join(i.dataDir, "config/certs"),
	)
	if err != nil {
		return err
	}

	err = linux.Chown(i.dataDir, App)
	if err != nil {
		return err
	}

	err = linux.Chown(storageDir, App)
	if err != nil {
		return err
	}
	return nil
}

func (i *Installer) ClearVersion() error {
	return os.RemoveAll(i.currentVersionFile)
}

func (i *Installer) UpdateVersion() error {
	return cp.Copy(i.newVersionFile, i.currentVersionFile)
}

func (i *Installer) UpdateConfigs() error {
	appUrl, err := i.platformClient.GetAppUrl(App)
	if err != nil {
		return err
	}

	domain, err := i.platformClient.GetAppDomainName(App)
	if err != nil {
		return err
	}

	jicofoPassword, err := getOrCreateUuid(i.jicofoPasswordFile)
	if err != nil {
		return err
	}

	variables := Variables{
		App:            App,
		AppDir:         i.appDir,
		DataDir:        i.dataDir,
		CommonDir:      i.commonDir,
		AppUrl:         appUrl,
		Domain:         domain,
		AuthDomain:     AuthDomain(domain),
		JicofoPassword: jicofoPassword,
	}

	err = config.Generate(
		path.Join(i.appDir, "config"),
		path.Join(i.dataDir, "config"),
		variables,
	)
	if err != nil {
		return err
	}

	err = cp.Copy(
		path.Join(i.appDir, "web", "index.html"),
		path.Join(i.dataDir, "web", "index.html"),
	)

	return nil
}

func (i *Installer) BackupPreStop() error {
	return i.PreRefresh()
}

func (i *Installer) RestorePreStart() error {
	return i.PostRefresh()
}

func (i *Installer) RestorePostStart() error {
	return i.Configure()
}

func (i *Installer) AccessChange() error {
	return i.UpdateConfigs()
}

func (i *Installer) FixPermissions() error {
	err := linux.Chown(i.dataDir, App)
	if err != nil {
		return err
	}
	err = linux.Chown(i.commonDir, App)
	if err != nil {
		return err
	}
	return nil
}

func getOrCreateUuid(file string) (string, error) {
	_, err := os.Stat(file)
	if os.IsNotExist(err) {
		secret := uuid.New().String()
		err = os.WriteFile(file, []byte(secret), 0644)
		return secret, err
	}
	content, err := os.ReadFile(file)
	if err != nil {
		return "", err
	}
	return string(content), nil
}

func AuthDomain(domain string) string {
	return fmt.Sprint("auth.", domain)
}
