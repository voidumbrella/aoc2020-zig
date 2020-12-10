const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    const run_all = b.step("runall", "Run all days");

    // Set up an exe for each day
    comptime var day = 1;
    inline while (day <= 25) : (day += 1) {
        @setEvalBranchQuota(100000);
        const day_string = comptime std.fmt.comptimePrint("day{:0>2}", .{day});
        const source_file = "src/" ++ dayString ++ ".zig";

        const exe = b.addExecutable(day_string, source_file);
        exe.setTarget(target);
        exe.setBuildMode(mode);

        exe.install();

        const install_cmd = b.addInstallArtifact(exe);

        const run_cmd = exe.run();
        run_cmd.step.dependOn(&install_cmd.step);
        if (b.args) |args|
            run_cmd.addArgs(args);

        const run_step = b.step(dayString, "Run " ++ dayString);
        run_step.dependOn(&run_cmd.step);

        run_all.dependOn(run_step);
    }
}
