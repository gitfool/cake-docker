#load nuget:?package=Cake.Dungeon&version=1.0.1-pre.2

Build.SetParameters
(
    title: "cake-docker",
    configuration: "Release",

    defaultLog: true,

    runDockerBuild: true,
    runPublishToDocker: true,

    dockerPushLatest: true,

    dockerImages: new[] { new DockerImage { Repository = "dockfool/cake-docker" } }
);

Build.Run();
