const std = @import("std");
const posix = std.posix;

pub const Winsize = struct {
    rows: usize,
    cols: usize,
    x_px: usize,
    y_px: usize,
};

pub const TerminalControl = struct {
    stdout: std.fs.File.Writer,
    stdin: std.fs.File.Reader,

    pub fn init() !TerminalControl {
        return TerminalControl{
            .stdout = std.io.getStdOut().writer(),
            .stdin = std.io.getStdIn().reader(),
        };
    }

    pub fn deinit(self: *TerminalControl) void {
        self.stdout.writeAll("\x1B[?25h") catch {};
    }

    pub fn clearScreen(self: *TerminalControl) !void {
        try self.stdout.writeAll("\x1B[2J");
    }

    pub fn moveCursor(self: *TerminalControl, row: u16, col: u16) !void {
        try self.stdout.print("\x1B[{};{}H", .{ row, col });
    }

    pub fn hideCursor(self: *TerminalControl) !void {
        try self.stdout.writeAll("\x1B[?25l");
    }

    pub fn showCursor(self: *TerminalControl) !void {
        try self.stdout.writeAll("\x1B[?25h");
    }

    pub fn setColor(self: *TerminalControl, fg: u8, bg: u8) !void {
        try self.stdout.print("\x1B[38;5;{}m\x1B[48;5;{}m", .{ fg, bg });
    }

    pub fn resetColor(self: *TerminalControl) !void {
        try self.stdout.writeAll("\x1B[0m");
    }

    pub fn readChar(self: *TerminalControl) !u8 {
        return self.stdin.readByte();
    }

    pub fn getTerminalSize(_: *TerminalControl) !Winsize {
        var winsize: posix.winsize = posix.winsize{
            .ws_row = 0,
            .ws_col = 0,
            .ws_xpixel = 0,
            .ws_ypixel = 0,
        };

        const err = posix.system.ioctl(posix.STDOUT_FILENO, posix.T.IOCGWINSZ, @intFromPtr(&winsize));

        if (posix.errno(err) == .SUCCESS) {
            return .{
                .rows = winsize.ws_row,
                .cols = winsize.ws_col,
                .x_px = winsize.ws_xpixel,
                .y_px = winsize.ws_ypixel,
            };
        } else {
            return error.UnableToGetTerminalSize;
        }
    }
};

// Control Sequences
// color
pub const BG_IDX = "\x1b[48;5;{d}m";
pub const FG_IDX = "\x1b[38;5;{d}m";
pub const BG_RGB = "\x1b[48;2;{d};{d};{d}m";
pub const FG_RGB = "\x1b[38;2;{d};{d};{d}m";

//
pub const MOVE_CURSOR = "\x1b[{};{}H";
