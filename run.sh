# todo: this should work not only on my computer
export LIBRARY_PATH=/home/marrow16180/Programming/Crystal/crsfml/voidcsfml
export LD_LIBRARY_PATH="$LIBRARY_PATH"

# debug
crystal main.cr

# release
#crystal main.cr --define release
