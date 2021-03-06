#!/usr/bin/perl -w
use strict;
use Parse::Eyapp;
use Data::Dumper;

my $grammar = q{
%{
use Data::Dumper;
%}
%right  '='
%left   '-' '+'
%left   '*' '/'
%left   NEG
%tree

%%
line: exp  { $_[1] } 
;

exp:      %name NUM   
            NUM 
	| %name VAR  
          VAR 
	| %name ASSIGN        
          VAR '=' exp 
	| %name PLUS 
          exp '+' exp 
	| %name MINUS       
          exp '-' exp 
	| %name TIMES   
          exp '*' exp 
	| %name DIV     
          exp '/' exp 
	| %name UMINUS
          '-' exp %prec NEG 
        |   '(' exp ')'  { $_[2] } /* Let us simplify a bit the tree */
;

%%

sub _Error {
        exists $_[0]->YYData->{ERRMSG}
    and do {
        print $_[0]->YYData->{ERRMSG};
        delete $_[0]->YYData->{ERRMSG};
        return;
    };
    print "Syntax error.\n";
}

sub _Lexer {
    my($parser)=shift;

        $parser->YYData->{INPUT}
    or  $parser->YYData->{INPUT} = <STDIN>
    or  return('',undef);

    $parser->YYData->{INPUT}=~s/^\s+//;

    for ($parser->YYData->{INPUT}) {
        s/^([0-9]+(?:\.[0-9]+)?)//
                and return('NUM',$1);
        s/^([A-Za-z][A-Za-z0-9_]*)//
                and return('VAR',$1);
        s/^(.)//s
                and return($1,$1);
    }
}

sub parse {
  my $p = shift;
  return $p->YYParse( yylex => \&_Lexer, yyerror => \&_Error, yydebug => 0x0 );
}
};

Parse::Eyapp->new_grammar(input=>$grammar, classname=>'Calc', outputfile => 'Calc');
my $p = Calc->new();
my $result = $p->parse();
$Data::Dumper::Indent = 1;
print Dumper($result);
