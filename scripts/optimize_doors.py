from pathlib import Path

FILE_PATH = Path("./SRC/maps/doors.asm")


def main():
    out = ""
    cur_door_name_0 = None
    cur_door_name_1 = None
    lines_0 = [] # from first label
    lines_1 = []
    with open(FILE_PATH, "r") as f:
        for line in f.readlines():
            if line.startswith("door"):
                if cur_door_name_0 is None:
                    cur_door_name_0 = line
                elif cur_door_name_1 is None:
                    cur_door_name_1 = line
                else:
                    if len(lines_1) and str(lines_0)[1:-1].endswith(str(lines_1)[1:-1]):
                        line_index = len(lines_0)-len(lines_1)
                        lines_compact = (
                            [cur_door_name_0] +
                            lines_0[:line_index] +
                            (["    ; fallthrough\n"] if line_index else []) 
                        )
                    else:
                        lines_compact = (
                            [cur_door_name_0] +
                            lines_0
                        )
                        #print(str(lines_0)[1:-1], "does not contain", str(lines_1)[1:-1])
                    out += "".join(lines_compact)
                    #
                    cur_door_name_0 = cur_door_name_1
                    cur_door_name_1 = line
                    lines_0 = lines_1
                    lines_1 = []
            else:
                if cur_door_name_1 is not None:
                    lines_1.append(line)
                elif cur_door_name_0 is not None:
                    lines_0.append(line)
        out += "".join(
            [cur_door_name_0] +
            lines_0 +
            [cur_door_name_1] +
            lines_1
        )

    print(out)

if __name__ == "__main__":
    main()

"""
door string suffix as dict key
add all sub-suffix
main string gets label list

"""