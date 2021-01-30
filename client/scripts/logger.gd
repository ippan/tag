class_name Logger

static func game_log(level: String, message: String) -> void:
    var datetime = OS.get_datetime()
    var formated_datetime = "%04d-%02d-%02d %02d:%02d:%02d" % [ datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute, datetime.second ]
    print("[%s][%s]%s" % [ formated_datetime, level, message ])

static func info(message: String) -> void:
    game_log("info", message)

static func warn(message: String) -> void:
    game_log("warn", message)

static func error(message: String) -> void:
    game_log("error", message)
