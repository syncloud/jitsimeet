local name = "jitsimeet";
local version = "stable-9584-1";
local nginx = '1.24.0';
local browser = "firefox";
local python = '3.12-slim-bookworm';
local debian = 'bookworm-slim';
local platform = '25.09';
local platform_buster = '25.02';
local selenium = '4.35.0-20250828';
local deployer = 'https://github.com/syncloud/store/releases/download/4/syncloud-release';
local distro_default = "bookworm";
local distros = ["bookworm", "buster"];

local build(arch, test_ui, dind) = [{
    kind: "pipeline",
    type: "docker",
    name: arch,
    platform: {
        os: "linux",
        arch: arch
    },
    steps: [
        {
            name: "version",
            image: "debian:" + debian,
            commands: [
                "echo $DRONE_BUILD_NUMBER > version"
            ]
        },
      {
         name: "jvb",
         image: "jitsi/jvb:" + version,
         commands: [
             "./jvb/build.sh " + version
         ]
     },
     {
       name: 'jvb test',
       image: 'syncloud/platform-' + distro_default + '-' + arch + ':' + platform,
       commands: [
         './jvb/test.sh',
       ],
     },
 {
      name: 'nginx',
      image: 'nginx:' + nginx,
      commands: [
        './nginx/build.sh',
      ],
    },
    {
      name: 'nginx test',
      image: 'syncloud/platform-' + distro_default + '-' + arch + ':' + platform,
      commands: [
        './nginx/test.sh',
      ],
    },
     {
        name: "web",
        image: "jitsi/web:" + version,
        commands: [
            "./web/build.sh " + version
        ]
    },
     {
        name: "prosody",
        image: "jitsi/prosody:" + version,
        commands: [
            "./prosody/build.sh " + version
        ]
    },
    {
      name: 'prosody test',
      image: 'syncloud/platform-' + distro_default + '-' + arch + ':' + platform,
      commands: [
        './prosody/test.sh',
      ],
    },
     {
        name: "jicofo",
        image: "jitsi/jicofo:" + version,
        commands: [
            "./jicofo/build.sh " + version
        ]
    },
    {
      name: 'jicofo test',
      image: 'syncloud/platform-' + distro_default + '-' + arch + ':' + platform,
      commands: [
        './jicofo/test.sh',
      ],
    },
        {
            name: "cli",
            image: "golang:1.24.0",
            commands: [
                "cd cli",
                "CGO_ENABLED=0 go build -buildvcs=false -o ../build/snap/meta/hooks/install ./cmd/install",
                "CGO_ENABLED=0 go build -buildvcs=false -o ../build/snap/meta/hooks/configure ./cmd/configure",
                "CGO_ENABLED=0 go build -buildvcs=false -o ../build/snap/meta/hooks/pre-refresh ./cmd/pre-refresh",
                "CGO_ENABLED=0 go build -buildvcs=false -o ../build/snap/meta/hooks/post-refresh ./cmd/post-refresh",
                "CGO_ENABLED=0 go build -buildvcs=false -o ../build/snap/bin/cli ./cmd/cli",
            ]
        },
        {
            name: "package",
            image: "debian:" + debian,
            commands: [
                "VERSION=$(cat version)",
                "./package.sh " + name + " $VERSION "
            ]
        }
       ] + [
           {
             name: 'test ' + distro,
             image: 'python:' + python,
             commands: [
               'cd test',
               './deps.sh',
               'py.test -x -s test.py --distro=' + distro + ' --ver=$DRONE_BUILD_NUMBER --app=' + name,
             ],
           }
           for distro in distros
] +
        ( if test_ui then [
         {
            name: "selenium",
            image: "selenium/standalone-" + browser + ":" + selenium,
            detach: true,
            environment: {
                SE_NODE_SESSION_TIMEOUT: "999999",
                START_XVFB: "true"
            },
               volumes: [{
                name: "shm",
                path: "/dev/shm"
            }],
            commands: [
                "cat /etc/hosts",
                "getent hosts " + name + ".buster.com | sed 's/" + name +".buster.com/auth.buster.com/g' | sudo tee -a /etc/hosts",
                "cat /etc/hosts",
                "/opt/bin/entry_point.sh"
            ]
         },
        {
            name: "selenium-video",
            image: "selenium/video:ffmpeg-6.1.1-20240621",
            detach: true,
            environment: {
                DISPLAY_CONTAINER_NAME: "selenium",
                FILE_NAME: "video.mkv"
            },
            volumes: [
                {
                    name: "shm",
                    path: "/dev/shm"
                },
               {
                    name: "videos",
                    path: "/videos"
                }
            ]
        },
        {
            name: "test-ui",
            image: "python:" + python,
            commands: [
              "cd test",
              "./deps.sh",
              "pip install -r requirements.txt",
              'py.test -x -s ui.py --distro=' + distro_default + ' --ver=$DRONE_BUILD_NUMBER --app=' + name + ' --browser=' + browser,
            ],
            volumes: [{
                name: "videos",
                path: "/videos"
            }]
        },
        {
            name: "test-upgrade",
            image: "python:" + python,
            commands: [
              "cd test",
              "./deps.sh",
              'py.test -x -s upgrade.py --distro=' + distro_default + ' --ver=$DRONE_BUILD_NUMBER --app=' + name + ' --browser=' + browser,
            ],
            privileged: true,
            volumes: [{
                name: "videos",
                path: "/videos"
            }]
        }
      ] else [] ) + [
        {
        name: "upload",
        image: "debian:" + debian,
        environment: {
            AWS_ACCESS_KEY_ID: {
                from_secret: "AWS_ACCESS_KEY_ID"
            },
            AWS_SECRET_ACCESS_KEY: {
                from_secret: "AWS_SECRET_ACCESS_KEY"
            },
            SYNCLOUD_TOKEN: {
                     from_secret: "SYNCLOUD_TOKEN"
                 }
        },
        commands: [
            "PACKAGE=$(cat package.name)",
            "apt update && apt install -y wget",
            "wget " + deployer + "-" + arch + " -O release --progress=dot:giga",
            "chmod +x release",
            "./release publish -f $PACKAGE -b $DRONE_BRANCH"
        ],
        when: {
            branch: ["stable", "master"],
	    event: [ "push" ]
}
    },
    {
            name: "promote",
            image: "debian:" + debian,
            environment: {
                AWS_ACCESS_KEY_ID: {
                    from_secret: "AWS_ACCESS_KEY_ID"
                },
                AWS_SECRET_ACCESS_KEY: {
                    from_secret: "AWS_SECRET_ACCESS_KEY"
                },
                 SYNCLOUD_TOKEN: {
                     from_secret: "SYNCLOUD_TOKEN"
                 }
            },
            commands: [
              "apt update && apt install -y wget",
              "wget " + deployer + "-" + arch + " -O release --progress=dot:giga",
              "chmod +x release",
              "./release promote -n " + name + " -a $(dpkg --print-architecture)"
            ],
            when: {
                branch: ["stable"],
                event: ["push"]
            }
      },
        {
            name: "artifact",
            image: "appleboy/drone-scp:1.6.4",
            settings: {
                host: {
                    from_secret: "artifact_host"
                },
                username: "artifact",
                key: {
                    from_secret: "artifact_key"
                },
                timeout: "2m",
                command_timeout: "2m",
                target: "/home/artifact/repo/" + name + "/${DRONE_BUILD_NUMBER}-" + arch,
                source: [
                    "artifact/*"
                ],
                privileged: true,
                strip_components: 1,
                volumes: [
                   {
                        name: "videos",
                        path: "/drone/src/artifact/videos"
                    }
                ]
            },
            when: {
              status: [ "failure", "success" ]
            }
        }
        ],
        trigger: {
          event: [
            "push",
            "pull_request"
          ]
        },
        services: [
        {
            name: "docker",
            image: "docker:" + dind,
            privileged: true,
            volumes: [
                {
                    name: "dockersock",
                    path: "/var/run"
                }
            ]
        }
            ] + [
    {
      name: name + '.' + distro + '.com',
      image: 'syncloud/platform-' + distro + '-' + arch + ':' + (if distro == 'buster' then platform_buster else platform),
      privileged: true,
      volumes: [
        {
          name: 'dbus',
          path: '/var/run/dbus',
        },
        {
          name: 'dev',
          path: '/dev',
        },
      ],
    }
    for distro in distros
  ],
        volumes: [
            {
                name: "dbus",
                host: {
                    path: "/var/run/dbus"
                }
            },
            {
                name: "dev",
                host: {
                    path: "/dev"
                }
            },
            {
                name: "shm",
                temp: {}
            },
            {
                name: "videos",
                temp: {}
            },
            {
                name: "dockersock",
                temp: {}
            },
     ]
    }];

build("amd64", true, "20.10.21-dind") +
build("arm64", false, "20.10.21-dind")
