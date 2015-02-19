#!/bin/bash

echo 'Running...'
nohup ./listener.rb 2>&1 > LISTENER.LOG &
echo 'Executed.'
