#load nuget:?package=Cake.Dungeon&version=1.0.0-pre.7

Build.SetParameters
(
    title: "cake-docker",
    configuration: "Release",

    defaultLog: true,

    runDockerBuild: true,
    runPublishToDocker: true,

    dockerImages: new[] { new DockerImage { Repository = "dockfool/cake-docker" } }
);

Build.Run();
