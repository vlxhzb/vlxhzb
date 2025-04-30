#!/usr/bin/env python
# encoding: utf-8
'''
Elasticsearch export using Python ES client's scroll feature
@author:     mbonaci
@copyright:  2016 Sematext. All rights reserved.
@license:    Apache 2.0
@contact:    marko.bonaci@sematext.com
'''

import sys
import os
import json

from optparse import OptionParser
from elasticsearch import Elasticsearch

__all__ = []
__version__ = 0.1
__date__ = '2019-11-11'
__updated__ = '2019-11-11'

DEBUG = 0
TESTRUN = 0
PROFILE = 0

def main(argv=None):
    '''Command line options.'''

    program_name = os.path.basename(sys.argv[0])
    program_version = "v0.2"
    program_build_date = "%s" % __updated__

    program_version_string = '%%prog %s (%s)' % (program_version, program_build_date)
    program_longdesc = '''Elasticsearch export using Python ES client's scroll feature, expanded for alarm log viewer'''
    program_license = "Copyright 2016 mbonaci (Sematext)                                            \
                Licensed under the Apache License 2.0\nhttp://www.apache.org/licenses/LICENSE-2.0"

    if argv is None:
        argv = sys.argv[1:]
    try:
        # setup option parser
        parser = OptionParser(version=program_version_string, epilog=program_longdesc, description=program_license)
        parser.add_option("--host", dest="host", help="set ES host name [default: %default]")
        parser.add_option("-p", "--port", dest="port", help="set ES port [default: %default]")
        parser.add_option("-f", "--facility", dest="status", help="select facility index [bii, mls, erl")
        parser.add_option("-f", "--from", dest="from", help="set starting timestamp (format: yyyy-MM-ddTHH:mm:ss[Z+03:00])")
        parser.add_option("-t", "--to", dest="to", help="set ending timestamp (format: yyyy-MM-ddTHH:mm:ss[Z+03:00])")
        parser.add_option("-y", "--severity", dest="severity", help="filter for severity, case insensitiv")
        parser.add_option("-s", "--status", dest="status", help="filter status, case insensitive")
        parser.add_option("-d", "--devices", dest="devices", help="filter for EPICS devices, phrase with * allowed")
        parser.add_option("-r", "--records", dest="records", help="filter for EPICS records, phrase with * allowed")
        parser.add_option("-o", "--out", dest="outfile", help="set output path [default: %default]", metavar="FILE")
        parser.add_option("-v", "--verbose", dest="verbose", action="count", help="set verbosity level [default: %default]")

        # set defaults
        parser.set_defaults(outfile="./out.txt", verbose=1, host="es.api.hostname.or.ip.address", port=443)

        # process options
        (opts, args) = parser.parse_args(argv)
        print args

        if opts.host:
            print("host = %s" % opts.host)
        if opts.port:
            print("port = %s" % opts.port)
        if opts.facility:
            print("facility = %s" % opts.facility)
        if opts.status:
            print("status = %s" % opts.status)
        if opts.severity:
            print("severity = %s" % opts.severity)
        if opts.devices:
            print("devices = %s" % opts.devices)
        if opts.records:
            print("records = %s" % opts.records)
        if opts.start:
            print("from = %s" % opts["from"])
        if opts.end:
            print("to = %s" % opts["to"])
        if opts.outfile:
            print("outfile = %s" % opts.outfile)
        if opts.verbose > 0:
            print("verbosity level = %d" % opts.verbose)

        # ES init #
        es = Elasticsearch([
          {'host': opts.host, 'port': opts.port, 'use_ssl': True}
        ])
        
        # Initialize the scroll
        query =  {
            "query": {
                "bool": {
                    "filter": {
                        "range": {
                        "@timestamp": {
                            "gte": opts["from"],
                            "lt": opts["to"]
                        }
                        }
                    },
                    "must": {
                        "match_all": {}
                    }
                }
            }
        }
        if opts.facility is not null:
            body["bool"]["must"][] = { "match": "_index": opts.facility + '-cmlog' }
        if opts.severity is not null:
            body["bool"]["must"][] = { "match": "cm_severity": opts.severity.upper }
        if opts.status is not null:
            body["bool"]["must"][] = { "match": "cm_status": opts.status.upper() }
        if opts.devices is not null:
            body["bool"]["must"][] = { "match_phrase": "epics_device": opts.devices }
        if opts.records is not null:
            body["bool"]["must"][] = { "match_phrase": "epics_record": opts.records }
        page = es.search(
            index = opts.token + '_2*',
            #doc_type = 'yourType',
            scroll = '5m',
            size = 200,
            body = query
        )
                
        sid = page['_scroll_id']
        scroll_size = page['hits']['total']
          
        f = open(opts.outfile, 'wb')
        json.dump(page['hits']['hits'], f)
        
        # Start scrolling
        while (scroll_size > 0):
            print "Scrolling..."
            page = es.scroll(scroll = '1m', body = {"scroll": "1m", "scroll_id": sid})  # 
            # Get the number of results that we returned in the last scroll
            scroll_size = len(page['hits']['hits'])
            print "scroll size: " + str(scroll_size) + "\n"
            # Dump the obtained result set into the output file
            json.dump(page['hits']['hits'], f)
        
        f.close()
        

    except Exception, e:
        indent = len(program_name) * " "
        sys.stderr.write(program_name + ": " + repr(e) + "\n")
        sys.stderr.write(indent + "  for help use --help")
        return 2


if __name__ == "__main__":
    if DEBUG:
        sys.argv.append("-h")
        sys.exit(0)
    sys.exit(main())
