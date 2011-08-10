#!/usr/bin/env python
# Creates platform-independent love file

import zipfile
import os
import re

binary	 = 'out.love'

lib_path = '/usr/local/lib/lua/5.1'
libs = [
    'leaf'
]

src_path = 'src'
patterns = ['\.lua', '\.png']

def main():
    out = zipfile.ZipFile(binary, 'w')
    for path, dirs, files in os.walk(src_path):
        for file in files:
            for pattern in patterns:
                if re.search(pattern, file):
                    full = os.path.join(path, file)
                    print 'Adding', full
                    out.write(full, os.path.relpath(full, src_path))

    # Bundle libs
    for lib in libs:
        abs_path = os.path.join(lib_path, lib)
        if lib.endswith('.lua'):
            print 'Bundling external library', abs_path
            out.write(abs_path, os.path.relpath(abs_path, lib_path))
        else:  # Assume dir
            for path, dirs, files in os.walk(abs_path):
                for file in files:
                    if file.endswith('.lua'):
                        full = os.path.join(path, file)
                        print 'Bundling external library', full
                        out.write(full, os.path.relpath(full, lib_path))
    out.close()

if __name__ == '__main__':
    main()
