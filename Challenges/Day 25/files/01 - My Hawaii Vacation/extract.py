#!/usr/bin/env python3
import re

def main():
    data = open("sample.lua").read()

    with open("decode.lua", "w") as fout:
        # Include __K, __T, __P and __D in the output.
        fout.write("\n".join(data.split("\n")[25:137]) + "\n")

        # Include all __D(string_here, __K) calls in the output.
        for item in re.findall(r"__D\(\"[^\"]+?\", __K\)", data):
            fout.write("print(%s);\n" % item)
    
if __name__ == "__main__":
    main()
