require "Spreadsheet/HTML/version"

module Spreadsheet
    class HTML

        def self.gen( *args )
            self.new.generate( *args )
        end

        def generate( *args )
            params = _process( args )

            if !params['theta']           # north
                params['data'] = params['flip'] ? params['data'].map {|a| a.reverse } : params['data']

            elsif params['theta'] == -90
#                $args{data} = [ reverse @{ _transpose( $args{data} ) }];
#                $args{data} = ($args{pinhead} and !$args{headless})
#                    ? [ map [ @$_[1 .. $#$_], $_->[0] ], @{ $args{data} } ]
#                    : [ map [ reverse @$_ ], @{ $args{data} } ];

            elsif params['theta'] == 90   # east
#                $args{data} = _transpose( $args{data} );
#                $args{data} = ($args{pinhead} and !$args{headless})
#                    ? [ map [ @$_[1 .. $#$_], $_->[0] ], @{ $args{data} } ]
#                    : [ map [ reverse @$_ ], @{ $args{data} } ];

            elsif params['theta'] == -180 # south
#                $args{data} = ($args{pinhead} and !$args{headless})
#                    ? [ @{ $args{data} }[1 .. $#{ $args{data} }], $args{data}[0] ]
#                    : [ reverse @{ $args{data} } ];

            elsif params['theta'] == 180
#                $args{data} = ($args{pinhead} and !$args{headless})
#                    ? [ map [ reverse @$_ ], @{ $args{data} }[1 .. $#{ $args{data} }], $args{data}[0] ]
#                    : [ map [ reverse @$_ ], reverse @{ $args{data} } ];

            elsif params['theta'] == 270
                params['data'] = params['data'].transpose.reverse

            elsif params['theta'] == -270 # west
                params['data'] = params['data'].transpose

            end

            return _make_table( params )
        end

        def initialize( *args )
            (args[0] || []).each do |key,val|
                self.instance_eval { class << self; self end }.send(:attr_accessor, key)
                self.send( "#{key}=", val )
            end
        end

        def _make_table( params )
            table = '<table>'

            params['data'].each do |row|
                table += '<tr>'
                row.each do |col|
                    table += '<' + col['tag'] + '>' + col['cdata'] + '</' + col['tag'] + '>'
                end
                table += '</tr>'
                tag = 'td'
            end

            table += '</table>'
            return table
        end

        def _process( args )
            params = _args( args )

            params['data'].shift if params['headless']

            data = []
            tag  = ( params['matrix'] or params['headless'] ) ? 'td' : 'th'

            params['data'].each do |row|
                r = []
                row.each do |col|
                    r.push( { 'tag' => tag, 'cdata' => col.to_s } )
                end
                data.push( r )
                tag = 'td'
            end
            params['data'] = data

            return params
        end

        def _args( things )

            data   = []
            args   = []
            while !things.empty?

                if things[0].kind_of?(Array)
                    data.push( things.shift() )
                    if things[0].kind_of?(Array)
                        data.push( things.shift() )
                    else
                        args.push( things.shift() ) if !things.empty?
                        args.push( things.shift() ) if !things.empty?
                    end
                else
                    args.push( things.shift() ) if !things.empty?
                    args.push( things.shift() ) if !things.empty?
                end

            end

            params = {}
            (args[0] || []).each do |key,val|
                params[key] = val
            end

            self.instance_variables.each do |attr|
                params[attr[1..-1]] = self.instance_variable_get attr
            end

            if !params['data'] and data[0].kind_of?(Array)
                data = [ data ] if !data[0][0].kind_of?(Array)
                params['data'] = data[0]
            end

            params['data'] = params['data'].clone

            return params
        end

    end
end
