package installer

import (
	"go.uber.org/zap"
	"os/exec"
	"strings"
)

type Ctl struct {
	prosodyCtl string
	logger     *zap.Logger
}

func (c *Ctl) Register(user, domain string, passwordFunc func() (string, error)) error {
	password, err := passwordFunc()
	if err != nil {
		return err
	}
	command := exec.Command(c.prosodyCtl, "register", user, domain, password)
	output, err := command.CombinedOutput()
	cmd := strings.Replace(command.String(), password, "***", -1)
	c.logger.Info("output", zap.String("cmd", cmd), zap.String("output", string(output)))
	return err
}

func (c *Ctl) Run(args ...string) error {
	command := exec.Command(c.prosodyCtl, args...)
	output, err := command.CombinedOutput()
	c.logger.Info("output", zap.String("cmd", command.String()), zap.String("output", string(output)))
	return err
}
