#!/usr/bin/python3

import sqlite3, sys, os

verbose_flag = False
dbdir_string = '/db/trac.db'
return_list = []

if (len(sys.argv) > 1):
    return_list.append('# trac2alias section')
    first_flag = True
    for arg_string in sys.argv:
        if first_flag is True:
            first_flag = False
            continue
        if verbose_flag:
                print('Checking argument "' + arg_string + '"')
        dir_string = arg_string + dbdir_string
        try:
            if verbose_flag:
                print('Using trac "' + dir_string + '"')
            db_connect = sqlite3.connect(dir_string)
            db_cursor = db_connect.cursor()
            return_list.append('# trac@' + arg_string)
            return_list.append('# begin')
            if verbose_flag:
                print('Connected to sqlite3')
            users_dict = {}
            for user_set in db_cursor.execute("select sid, value from session_attribute where name='email';"):
                users_dict[user_set[0]] = user_set[1]
            if verbose_flag:
                print(str(len(users_dict.keys())) + ' users imported')
            buffer_list = []
            for component_set in db_cursor.execute("select c.owner, d.cc, a.value as mail from component c, component_default_cc d, session_attribute a where c.name=d.name and c.owner=a.sid and a.name='email' order by a.value;"):
                if (component_set[0].startswith('_', 0, 1)):
                    if verbose_flag:
                        print('Build entry for "' + str(component_set[0]) + '"')
                    alias_list = component_set[2].split('@')
                    alias_string = str(alias_list[0])
                    users_list = component_set[1].split(', ')
                    set_list = []
                    for user in users_list:
                        if user in users_dict.keys():
                            set_list.append(users_dict[user])
                        elif '@' in user:
                            set_list.append(user)
                    if verbose_flag:
                        print(str(len(set_list)) + ' converted users.')
                    buffer_list.append(alias_string + ': ' + ', '.join(set_list))
            if len(buffer_list) > 0:
                buffer_list.sort()
                return_list = return_list + buffer_list
            return_list.append('# end')
            return_list.append('')
            db_connect.close()
        except sqlite3.Error as sql_error:
            print('SQLite[' + dir_string + ']: ' + format(sql_error))
            sys.exit(-2)

if len(return_list) > 0:

    if verbose_flag:
        print(str(len(return_list)) + ' entries generated.')
    print ("\n".join(return_list))
else:
    print("No trac source found.\nUsage: " + sys.argv[0] + " (tracdir[ tracdir]) [-v]")
    if verbose_flag:
        print('No entries generated.')
