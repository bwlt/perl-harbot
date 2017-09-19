#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use LWP::UserAgent();
use JSON::Parse 'parse_json';

# insert your token here
my $TOKEN = "";
my $LP_TIMEOUT = 10;


sub parse_response {
  my $response = $_[0];
  my $content = $response->decoded_content;
  my $parsed = parse_json($content);

  return $parsed
}


sub process_response {
  my $response = $_[0];
  my $parsed = parse_response($response);

  if (!$parsed->{ok}) { die "not ok"; }
  my $updates = $parsed->{result};
  for my $update (@$updates) {
    print Dumper $update;
    my $message = $update->{message};
    if (!defined($message->{entities})) {
      next;
    }
    my $entities = $message->{entities};
    my @bot_command_entities = ();
    foreach my $entity (@$entities) {
      if ($entity->{type} eq "bot_command") {
        push(@bot_command_entities, $entity);
      }
    }
    if (scalar @bot_command_entities eq 0) {
      # no entities to process
      next;
    }
    my $first = $bot_command_entities[0];
    my $command = substr $message->{text}, $first->{offset}, $first->{length};
    for ($command) {
      if ("help") {
        print "help"
      }
      else {
        print "asd"
      }
    }
    print Dumper $command;
  }
}


sub loop {
  my $ua = LWP::UserAgent->new;
  for (;;) {
    my $response = $ua->get("https://api.telegram.org/bot$TOKEN/getUpdates?timeout=$LP_TIMEOUT");

    if ($response->is_success) {
      process_response($response)
    }
    else {
      die "not success";
    }
    sleep 10;
  }
}


sub main {
  loop
}


main;
