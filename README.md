# synology-storage
Get storage stats of a share on your Synology box in the command line

# Preview
![Preview](https://github.com/rasiquiz/synology-storage/blob/master/preview.png?raw=true)

# Setup
Open the file in your favorite text editor and change the following:
- USERNAME: with your synology nas username
- PASSWORD: with the password the said username
- NAS ADDRESS: with the IP or web address of the synology nas
- SHARE NAME: with the name of the share you want stats on (Thinking about adding support for multiple shares)
- TITLE TO BE SHOWN: with whatever you want to be shown as the title (don't remove the spaces before and after the title)


# Usage
Place it somewhere on your computer and invoke it either via:

    sh syno-storage.sh

or you can create a line in your .bash_profile so you can invoke it via a custom command. I have linked it to the word "nas"

    alias nas='sh /PATH/TO/FILE/syno.sh'

