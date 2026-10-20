local name = "jitsimeet";
local version = "stable-11248";
local image_repo = "ghcr.io/jitsi";
local nginx = '1.24.0';
local python = '3.12-slim-bookworm';
local debian = 'bookworm-slim';
local platform = '26.07.01';
local go = '1.24.0';
local playwright = 'v1.48.2-jammy';
local store_publisher = "stable-346";
local distro_default = "bookworm";
local distros = ["bookworm", "buster"];

local platform_image(distro) = 'syncloud/platform-' + distro + ':' + platform;

local build(arch, test_ui) = [{
    kind: "pipeline",
    type: "docker",
    name: arch,
    platform: {
        os: "linux",
        arch: arch
    },
    steps: [
      {
         name: "jvb",
         image: image_repo + "/jvb:" + version,
         user: "root",
         commands: [
             "./jvb/build.sh " + version
         ]
     },
     {
       name: 'jvb test',
       image: platform_image(distro_default),
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
      image: platform_image(distro_default),
      commands: [
        './nginx/test.sh',
      ],
    },
     {
        name: "web",
        image: image_repo + "/web:" + version,
        user: "root",
        commands: [
            "./web/build.sh " + version
        ]
    },
     {
        name: "prosody",
        image: image_repo + "/prosody:" + version,
        user: "root",
        commands: [
            "./prosody/build.sh " + version
        ]
    },
    {
      name: 'prosody test',
      image: platform_image(distro_default),
      commands: [
        './prosody/test.sh',
      ],
    },
     {
        name: "jicofo",
        image: image_repo + "/jicofo:" + version,
        user: "root",
        commands: [
            "./jicofo/build.sh " + version
        ]
    },
    {
      name: 'jicofo test',
      image: platform_image(distro_default),
      commands: [
        './jicofo/test.sh',
      ],
    },
        {
            name: "cli",
            image: "golang:" + go,
            commands: [
                "./cli/build.sh"
            ]
        },
        {
            name: "package",
            image: "debian:" + debian,
            commands: [
                "./package.sh " + name + " $DRONE_BUILD_NUMBER"
            ]
        }
       ] + [
           {
             name: 'test ' + distro,
             image: 'python:' + python,
             commands: [
               './ci/test.sh test.py ' + distro + ' ' + name,
             ],
           }
           for distro in distros
] +
        ( if test_ui then [
         {
            name: "e2e",
            image: "mcr.microsoft.com/playwright:" + playwright,
            commands: [
                "./test/e2e/run.sh e2e specs/01-jitsimeet.spec.ts " + distro_default,
            ]
         },
        {
            name: "test-upgrade",
            image: "python:" + python,
            commands: [
              "./ci/test.sh upgrade.py " + distro_default + " " + name,
            ]
         }
      ] else [] ) + [
        {
            name: "publish",
            image: "syncloud/store-publisher:" + store_publisher,
            environment: {
                SYNCLOUD_TOKEN: { from_secret: "SYNCLOUD_TOKEN" }
            },
            command: ["snap", "-c", "${DRONE_BRANCH}"],
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
                strip_components: 1
            },
            when: {
              status: [ "failure", "success" ]
            }
        }
        ],
        trigger: {
          event: [
            "push"
          ]
        },
        services: [
    {
      name: name + '.' + distro + '.com',
      image: platform_image(distro),
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
     ]
    }];

build("amd64", true) +
build("arm64", false)
