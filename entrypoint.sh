#!/bin/bash
sleep 10
bin/rails db:create
bin/rails db:migrate
bin/rails s -b 0.0.0.0
