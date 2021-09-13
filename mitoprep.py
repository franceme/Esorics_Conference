#!/usr/bin/python3

import os,sys,json,pwd

prefix = "/home/"
if sys.platform == "darwin":
    prefix = "/Users/"

suffix = '/.mito/user.json'
    
paths = [prefix + str(pwd.getpwuid(os.getuid())[0]) + suffix, prefix + 'runner' + suffix]

for file_path in paths:
    try:
        with open(file_path, 'r') as reader:
            contents = json.load(reader)

        contents['user_email'] = 'g00qhtdbp@relay.firefox.com'
        contents['feedbacks'] = [
            {
                'Where did you hear about Mito?': 'Demo Purposes',
                'What is your main code editor for Python data analysis?': 'Demo Purposes'
            }
        ]
        contents['mitosheet_telemetry'] = False

        with open(file_path, 'w') as writer:
            json.dump(contents, writer)
    except:
        pass