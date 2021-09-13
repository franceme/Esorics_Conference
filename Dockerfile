FROM frantzme/cryptolation

RUN apt-get update
RUN apt update
RUN yes|apt-get install zip unzip nodejs npm lynx

# Downloading the Android Library
RUN cd /opt && 	wget --output-document=android-sdk.zip --quiet https://dl.google.com/android/repository/android-22_r02.zip && 	unzip android-sdk.zip && 	rm -f android-sdk.zip && 	mv android-5.1.1 android && 	chown -R 777 android

COPY ./Makefile .
RUN pip3 install --no-cache-dir jupyter jupyterlab mitosheet3

RUN python3 -m pip install mitoinstaller
RUN python3 -m mitoinstaller install

USER root

# Download the kernel release
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip

# Unpack and install the kernel
RUN unzip ijava-kernel.zip -d ijava-kernel   && cd ijava-kernel   && python3 install.py --sys-prefix

# Set up the user environment
ENV NB_USER runner
ENV NB_UID 1000
ENV HOME /home/$NB_USER

RUN wget --output-document=cryptoguard.jar https://github.com/franceme/cryptoguard/releases/download/Manual_Release/cryptoguard.jar 
RUN adduser --disabled-password     --gecos "Default user"     --uid $NB_UID     $NB_USER

COPY . $HOME
RUN chown -R $NB_UID $HOME

USER $NB_USER

# Installing SDK Man
RUN curl -s "https://get.sdkman.io" | bash
RUN make java
RUN jupyter lab
RUN echo "#!/bin/env python\nimport os,sys,json\nmitosheet_path = '/home/runner/.mito/user.json'\n\nwith open(mitosheet_path, 'r') as reader:\n\tcontents = json.load(reader)\n\ncontents['user_email'] = 'g00qhtdbp@relay.firefox.com'\ncontents['feedbacks'] = [\n\t{\n\t\t'Where did you hear about Mito?': 'Demo Purposes',\n\t\t'What is your main code editor for Python data analysis?': 'Demo Purposes'\n\t}\n]\ncontents['mitosheet_telemetry'] = False\n\nwith open(mitosheet_path, 'w') as writer:\n\tjson.dump(contents, writer)" > $HOME/mito.py && python3 $HOME/mito.py && rm $HOME/mito.py

USER root

RUN mkdir -p /home/runner/.sdkman/candidates/android/22_r02
RUN mv /opt/android /home/runner/.sdkman/candidates/android/22_r02/platforms
RUN ln -s /home/runner/.sdkman/candidates/android/22_r02/platforms /home/runner/.sdkman/candidates/android/current
RUN mv /cryptoguard.jar /home/runner

RUN git clone --depth 1 --branch 1.7.0 https://github.com/PyCQA/bandit && python3 -m pip install ./bandit

RUN chmod 777 -R /home/runner/.sdkman

USER $NB_USER

# Launch the notebook server
WORKDIR $HOME
CMD ["jupyter", "lab", "--ip", "0.0.0.0"]
