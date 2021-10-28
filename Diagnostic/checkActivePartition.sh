#!/bin/bash
#/******************************************************************************
# *
# * Copyright (c) 2021 Phoenix Contact GmbH & Co. KG. All rights reserved.
# * Licensed under the MIT. See LICENSE file in the project root for full license information.
# *
# ******************************************************************************/
rauc status --detailed

df -ha | grep rw
df -ha | grep ro
df -ha | grep external
df -ha | grep internal
