#load nuget:?package=Cake.Dungeon&version=1.0.0-pre.6

Build.SetParameters
(
    title: "cake-docker",
    configuration: "Release",

    defaultLog: true,

    runDockerBuild: true,
    runPublishToDocker: true,

    containerRepository: "dockfool/cake-docker"
);

Build.Run();
