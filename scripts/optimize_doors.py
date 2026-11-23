from pathlib import Path

FILE_PATH = Path("./SRC/maps/doors.asm")


class DoorDataLevel:
    def __init__(self):
        self.dict = {}
        self.labels = []

    def to_asm(self):
        asm = []
        
        for k, v in self.dict.items():
            v_asm = [a + k for a in v.to_asm()]
            asm += v_asm
        
        if len(asm) == 0:
            asm.append("")

        # asm index could be anything, but putting it at the end
        # makes the doors having undefined instructions more obvious
        asm[len(asm)-1] += "".join(self.labels)

        return asm


class DoorDataRun:
    def __init__(self):
        self.labels_of_lines = [[]]
        self.lines = []

    def add_label(self, label):
        self.labels_of_lines[len(self.labels_of_lines)-1].append(label)

    def add_line(self, label):
        self.lines.append(label)
        self.labels_of_lines.append([])

    def commit_to_levels(self, door_dict):
        sub_door_dict = door_dict
        
        for labels, line in zip(reversed(self.labels_of_lines), reversed(self.lines)):
            sub_door_dict.labels += labels

            if line not in sub_door_dict.dict:
                sub_door_dict.dict[line] = DoorDataLevel()
            sub_door_dict = sub_door_dict.dict[line]
        
        sub_door_dict.labels += self.labels_of_lines[0]


def main():
    out = ""
    door_data_levels = DoorDataLevel()
    door_data_run = None

    with open(FILE_PATH, "r") as f:
        for line in f.readlines():
            if line.startswith("door"):
                # label
                if door_data_run is None:
                    door_data_run = DoorDataRun()
                door_data_run.add_label(line)
            else:
                # not label
                if line.strip() == "":
                    continue
                if door_data_run is None:
                    # ptr table
                    out += line
                else:
                    # door line
                    door_data_run.add_line(line)
                    if "END_DOOR" in line:
                        door_data_run.commit_to_levels(door_data_levels)
                        door_data_run = None
    if door_data_run is not None:
        door_data_run.commit_to_levels(door_data_levels)
        door_data_run = None

    out += "\n\n" + "\n".join(door_data_levels.to_asm())
    with open(FILE_PATH, "w") as f:
        f.write(out)


if __name__ == "__main__":
    main()
