package HTML::Xml;

package HTML::Leaf;

sub new {
    my $P = shift;
    my $O = {};
    bless $O,ref $P || $P;
    $xml_obj = shift;
    $func    = shift;
    $indx    = shift;
    $O->{xml_obj} = $xml_obj;
    $O->{func} = $func;
    $O->{index}= $indx;
    $O->{value} = $xml_obj->{KV}->{$func}->[$indx];
    my $value = $O->{value};
    return $O;
}

sub value {
    my $O = shift;
    return $O->{value};
}

sub AUTOLOAD {
    my $O = shift;
    my $attr = $HTML::Leaf::AUTOLOAD;
    $attr =~ s/.*:://;
    return if $attr eq 'DESTROY';
    my $xml_obj = $O->{xml_obj};
    my $func    = $O->{func};
    my $index   = $O->{index};

    return $xml_obj->$func([$attr],$index);
}

1;

#================================

package HTML::Xml;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
array
);
$VERSION = '0.01';


# Preloaded methods go here.

my $obj_id = 0;

sub new {
    my $P = shift;
    my $O = {};
    bless $O,ref $P || $P;
    $O->{ID} = $obj_id++; # each object has its uniq id
    $O->{name}  = shift;
    $O->{K}  = []; # contains key names "something"
    $O->{V}  = []; # contains values for keys
    $O->{KV} = (); # contains key value  pairs
    $O->{ARG}= (); # contains argument (unit) <temperature unit=F>98</temperature>
    $O->{HASH}= (); # contains key=unit value=number which is incrimented
    return $O;
}

=pod
sub array() {
#   my $O = shift;
    my $temp = shift;
    my @arr = ();
    if(ref($temp) eq "ARRAY") {
       @arr = @$temp;
    } else {
       $arr[0] = $temp;
    }
    return @arr;
}
=cut
# AUTOLOAD is used to set values or to get values
# if there is no argument it is to get values
# if there is argument it is to set values
sub AUTOLOAD {
    my $O = shift;
    my $func = $HTML::Xml::AUTOLOAD;
    $func =~ s/.*:://;
    return if $func eq 'DESTROY';

    if( @_) {
       # AUTOLOAD is used in set mode  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
       my $argm = shift; 
       if(ref($argm) eq "ARRAY") { # used in get mode with array ref <<<<<
          my $mmm = $argm->[0];
          my $id = $O->{ID};
          my $indx = 0;
          if(@_) {
             $indx = shift;
          }
          $id .= $indx;
          my $keyy = $func.$mmm.$id;
          my $str = $O->{ATTR0}->{$keyy};
          return $str;
       }
       if( @_ ) { # there is attributes in the argument 
          my $args = shift;
          my @arrr = ( %$args );
          my $ssss = join(" ",@arrr);
          $ssss =~ s/=/ /g;
          $args = { split(" ",$ssss) };
          my $key;
          my $temp = "";
          my $indx;
          my $keyy;
          my $id;
          foreach $key ( keys %$args ) {
             $id = $O->{ID};
             $temp .= " $key = ".$args->{$key};
             $keyy = $func.$key; 
             $indx = $O->{HASH}->{$keyy}; 
             if($indx) {
                 $indx++;
             } else {
                 $indx = 1;
             }
             $indx--;
             $id .= $indx;
             $indx++;
             $O->{HASH}->{$keyy} = $indx;
             $O->{index} = $indx;    # this is new
             my $keyyy = $keyy.$id;
             $O->{ATTR0}->{$keyyy} = $args->{$key};
          }
          $O->{ATTR}->{$func.$id} = $temp;
       }
       push(@{$O->{K}},$func);
       push(@{$O->{V}},$argm);
       push(@{$O->{KV}->{$func}},$argm);
       return;
    }
    # AUTOLOAD is used in get mode  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    if($O->{KV}->{$func}) {
       if(wantarray) {
          my @values = @{$O->{KV}->{$func}};
          my $obj;
          my @arr = ();
          my $i   = 0;
          foreach $obj ( @values ) {
             if(ref($obj) eq "HTML::Xml") {
                push(@arr, $obj);
             } else {
                if($#values == 0) {
                   my $key  = $func.$O->{ID}.$i;
                   if($O->{ATTR}->{$key}) {
                      my $leaf = HTML::Leaf->new($O,$func,0);
                      return $leaf;
                   } else {
                      return $values[0];
                   }
                } else {
                   my $leaf = HTML::Leaf->new($O,$func,$i);
                   push(@arr, $leaf);
                }
             }
             $i++;
          }
          return @arr;
       } else {
          return $O->{KV}->{$func}->[0];
       }
    } else {
       if(wantarray) {
          return ();  # array is not defined return empty array
       } else {
          return ""; # value is not defined return empty string
       }
    }
}

sub count {                            
  
  my $O = shift;               
  my $name = @_[0]; 
 
  my @ark = @{$O->{K}};             
  my @arv = @{$O->{V}};            
  my $key;  
  my $count = 0;                 
 
  my $i = 0;  
  foreach $key ( @ark ) {       
    my $temp = $arv[$i];  
                        
    if ($name eq $temp->{name} ) 
    {                                     
      $count++; 
    }                                                
    $i++; 
  }                         
  return $count; 
   
}     
   
sub print {
    my $O = shift;
    print $O->string;
}

sub string {
    my $O = shift;
    my $str = "";
    if( !@_ ) {
#      $str .= "Content-type: text/plain\n\n";
       $str .= "<?xml version=\"1.0\"?>\n";
    }
    my $space = shift;
    my $space1 = $space."   ";
    my @ark = @{$O->{K}};
    my @arv = @{$O->{V}};
    my $key;
    $str .= $space."<".$O->{name}.">\n";
    my $i = 0;
    my $j = 0;
    my $id = $O->{ID};
    my %hash = ();
    foreach $key ( @ark ) {
       if($hash{$key}) {
          $hash{$key}++;
       } else {
          $hash{$key} = 1; 
       }
       $j = $hash{$key} - 1;
       my $temp = $arv[$i];
       if(ref($temp) eq "HTML::Xml") {
          $str .= $temp->string($space1)."\n";
       } elsif(ref($temp) eq "ARRAY") {
          my $ttt;
          foreach $ttt ( @{$temp}) { 
             $str .= "$space1<".$key."$O->{ATTR}->{$key.$id.$j}>".$ttt."</".$key.">"."\n";
          }
       } else {
          $str .= "$space1<".$key."$O->{ATTR}->{$key.$id.$j}>".$temp."</".$key.">"."\n";
       }
       $i++;
    }
    $str .= "$space</".$O->{name}.">";
    return $str;
}

sub parse {
    my $P   = shift;
    my $str = shift;
    _parse($str);
}
    
sub read {
    my $P    = shift;
    my $file = shift;
    open(FILE, $file) or die @!;
    my $str; 
    while(<FILE>) {
       $str .= $_;
    }
    _parse($str);
}

sub _parse {
    my $O;
    my $str = shift;
    my @obj = ();
    # remove all spaces and new lines between > and </
    $str =~ s/>[ \n]*</></g;
    # remove all spaces and new lines at the end of string
    $str =~ s/>[ \n]*$/>/g;

    # first remove all comments from string
    $str =~ s/<!--[^<>]*-->//g;
    # remove xml decleration line, if there is need we can process it later
    $str =~ s/<\?.*\?>//g;
    # remove DOCTYPE decleration, if there is need we can process it later
    $str =~ s/<! *DOCTYPE .>//g;
    # remove <!ELEMENT ...> lines 
    $str =~ s/<!ELEMENT .>//g;
    # @arr contains arrays in each cell. The contained arrays 
    # are called @sarr ( small array ) and contains four values
    # assume that we want to parse following statement
    # <something a='A' b='B'>value</something> 
    # $sarr[0] contains something
    # $sarr[1] contains either 1 or 2 
    #          if it is 1 that means we matched <something a='A' b='B'>
    #          if it is 2 that means we matched </something>
    # $sarr[2] contains value if $sarr[1] == 1 or else it is empty
    # $sarr[3] contains match value which is
    # <something a='A' b='B'> if $sarr[1] == 1 or
    # </something> if $sarr[1] == 2 
    my @arr = ();
    while($str ne "") {
        $_ = $str;
        m/<([a-zA-z0-9:_]+)[-=a-zA-Z0-9:.'" ]*>|<\/([a-zA-z0-9:_]+)>/;
        my @sarr = ();
        if($1 ne "") {
           push(@sarr,$1);
           push(@sarr,1);
        } else {
           push(@sarr,$2);
           push(@sarr,2);
        }
        push(@sarr,$`);
        push(@sarr,$&);
#       print "DOLAR1 = $sarr[0] \n";
#       print "DOLAR2 = $sarr[1] \n";
#       print "VALUE  = $sarr[2] \n";
#       print "MATCH  = $sarr[3] \n"; 
        $str = $'; # whatever string left after the match
        # check whether keys contain any arguments
        if($sarr[1] == 1) {
           # process arguments <<<<<<<<<<<<<<<<<<<<<<<<<<<<
           my $arg = $sarr[0];
           my $tp = $&;
           $tp =~ s/$arg//;  # remove key from string
           $tp =~ s/ *< *//; # remove < and spaces around it 
           $tp =~ s/ *> *//; # remove > and spaces around it
           $tp =~ s/ *= */\=/g; # remove > and spaces around it
           if($tp ne "") {
              my $args = {split(" ",$tp)};
              push(@sarr,$args); # matched text itself
           }
        }
        push(@arr,\@sarr);
    } 
    my $len = $#arr;
    my @ar1 = @{$arr[0]};
    my @ar2 = @{$arr[1]};
    my $root = $ar1[0];
    $O = HTML::Xml->new($ar1[0]); 
    push(@obj,$O);
    my $i = 1;
    while($i != $len) {
       @ar1 = @{$arr[$i]};
       my $slen = $#ar1;
       my $key1 = $ar1[0];
       if($root ne $key1) {
          @ar2 = @{$arr[$i+1]};
          my $key2 = $ar2[0];
          if($key1 eq $key2) {
             if($ar1[1] == 1) {
                my $obj = $obj[$#obj];
                # ----------------------------
                my $func = $key1;
                my $arg  = $ar2[2];
                if($slen == 4) {
                   $obj->$func($arg,$ar1[4]);
                } else {
                   $obj->$func($arg);
                }
                # ----------------------------
                $i += 2;
             } else {
                # first pop value from object stack
                $#obj  = $#obj-1; 
                my $slen = $#ar2; # overrite slen
                my $temp = HTML::Xml->new($key1);
                my $obj = $obj[$#obj];
                # ----------------------------
                if($slen == 4) {
                   $obj->$key1($temp,$ar2[4]);
                } else {
                   $obj->$key1($temp);
                }
                # ----------------------------
                # then add new obj to stack
                push(@obj,$temp);
                $i += 2;
             }
          } else {
             if($ar1[1] == 1) { # this is beginning of new object
                my $temp = HTML::Xml->new($key1); 
                my $obj = $obj[$#obj];
                # ----------------------------
                if($slen == 4) {
                   $obj->$key1($temp,$ar1[4]);
                } else {
                   $obj->$key1($temp);
                }
                # ----------------------------
=pod
                if($slen == 4) {
                   my $key;
                   foreach $key ( keys %{$ar1[4]} ) {
                      my $kk = $key1."_".$key;
                      $temp->{$kk} = $ar1[4]->{$key};
                   }
                }
=cut
                push(@obj,$temp);
             } else { # this is closing for previous object
                $#obj  = $#obj-1; # popup a value from stack
             }
             $i++;
          }
       }
    }
   
    return $O;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

HTML::Xml - Perl extension for parsing and generating Xml documents.
(nonvalidating) 

=head1 SYNOPSIS

   use HTML::Xml;
   use strict;

   my $dom = HTML::Xml->parse("
      <person>
        <fname>Seyhan</fname>
        <lname>Ersoy</lname>
      </person>");

   my $fname = $dom->fname;
   my $lname = $dom->lname;

   print "$fname $lname \n";


=head1 DESCRIPTION

Stub documentation for HTML::Xml was created by h2xs.
HTML::Xml has many futures to parse and create Xml documents.
Since it has many futures, I wanted
to show all the futures of this module by using simple programs.
This programs also help me to find bugs. After a change in the
module I run these programs for possible bugs. You can find these
programs at

http://users.rcn.com/seyhan

If you have any question, or you want to have simple program to show
how the particular future of HTML::Xml is used, send me an e-mail
at

seyhan@rcn.com


=head1 AUTHOR

Seyhan Ersoy, seyhan@rcn.com
Documentation of HTML::Xml is located at.
http://users.rcn.com/seyhan

=head1 COPYRIGHT

You may use and distribute HTML::Xml module
under the terms of either the GNU General Public
License or the Artistic License, as specified in the Perl README file.

=head1 ACKNOWLEDGEMENTS

I would like to acknowledge the valuable contributions of the many
people I have worked with.
I also thank my wife Zeynep Ersoy for her patience and support.

=head1 SUPPORT / WARRANTY

The HTML::Xml is free software. IT COMES WITHOUT WARRANTY OF ANY KIND.

=head1 SEE ALSO

perl(1).

=cut
