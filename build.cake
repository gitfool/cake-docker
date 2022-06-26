#load nuget:?package=Cake.Dungeon&prerelease

Build.SetParameters
(
    title: "cake-docker",

    defaultLog: true,

    runDockerBuild: true,
    runPublishToDocker: true,

    dockerBuildCache: true,
    dockerPushLatest: true,
    dockerPushSkipDuplicate: true,

    dockerImages: new[]
    {
        new DockerImage
        {
            Repository = "dockfool/cake-docker",
            Platforms = new[] { "linux/amd64", "linux/arm64" }
        }
    }
);

Build.Run();
