#!/usr/bin/perl

use strict;
use warnings;
use Socket qw(inet_pton inet_ntop AF_INET6);
use Math::BigInt;
use Digest::MD5 qw(md5_hex);

# Function to convert IPv6 address to a Math::BigInt
sub ipv6_to_bigint {
    my ($ipv6) = @_;
    my $address = inet_pton(AF_INET6, $ipv6) or die "Invalid IPv6 address: $ipv6";
    return Math::BigInt->from_bytes($address);
}

# Function to convert Math::BigInt to IPv6 address
sub bigint_to_ipv6 {
    my ($bigint) = @_;
    my $address = $bigint->to_bytes();
    $address .= "\0" x (16 - length($address)); # Pad to 16 bytes
    return (inet_ntop(AF_INET6, $address) or die "Failed to convert bigint to IPv6");
}

# Function to calculate the number of addresses in a CIDR block
sub cidr_size {
    my ($prefix_length) = @_;
    return Math::BigInt->new(2) ** (128 - $prefix_length);
}

# Function to seed the random number generator from a string
sub seed_rng {
    my ($seed_string) = @_;

    # Hash the seed string using MD5 to generate a hexadecimal representation
    my $md5_hex = md5_hex($seed_string);

    # Convert the hexadecimal representation to a decimal number
    my $decimal_seed = Math::BigInt->from_hex($md5_hex)->as_number();

    # Seed the random number generator
    no warnings "overflow";
    srand($decimal_seed);
    use warnings "overflow";
}

# Main execution block
{
    # Get CIDR, prefix lengths, and seeds from command line arguments
    my $cidr = shift @ARGV or die "Usage: $0 <cidr> <prefix_length1> [<prefix_length2> ...] <seed1> [<seed2> ...]";
    my @prefix_lengths = (); # Now storing prefix lengths instead of address counts
    my @seeds = ();

    # Parse CIDR block
    my ($network, $prefix) = split /\//, $cidr;
    my $prefix_length = int($prefix);

    # Validate CIDR
    unless (defined $network && defined $prefix_length && $prefix_length >= 0 && $prefix_length <= 128) {
        die "Invalid CIDR format.";
    }

    # Find the index where seeds start.
    my $seed_start_index = -1;
    for (my $i = 0; $i < @ARGV; $i++) {
        if ($ARGV[$i] =~ /^\d+$/) { # If it is an integer assume it is a prefix length
            push @prefix_lengths, int($ARGV[$i]);
        } else {
            $seed_start_index = $i;
            last;
        }
    }

    # Extract the seeds
    if ($seed_start_index != -1) {
        @seeds = @ARGV[$seed_start_index .. $#ARGV];
    } else {
        die "Must specify at least one seed.";
    }

    # Check if any prefix lengths were specified
    if (@prefix_lengths == 0) {
        die "Must specify at least one prefix length.";
    }

    # Validate the prefix lengths
    foreach my $len (@prefix_lengths) {
        unless ($len =~ /^\d+$/ && $len >= $prefix_length && $len <= 128) {
            die "Prefix lengths must be integers between $prefix_length and 128.";
        }
    }

    # Convert IPv6 network address to a Math::BigInt
    my $network_bigint = ipv6_to_bigint($network);

    # Calculate the total number of addresses in the CIDR
    my $total_addresses = cidr_size($prefix_length);

    # Calculate the total requested address space.
    my $total_requested = Math::BigInt->new(0);
    foreach my $len (@prefix_lengths){
        $total_requested += cidr_size($len); #Sum the space based on the prefixes
    }

    #Die if the address space is not big enough
    if($total_requested * @seeds > $total_addresses){
        die "Not enough address space to fulfill the request";
    }

    # Calculate the address space to use for each seed.  Divide by number of seeds
    my $address_space_per_seed = Math::BigInt->new(int($total_addresses / @seeds));

    # Main loop: process each seed
    for (my $seed_index = 0; $seed_index < @seeds; $seed_index++) {
        my $seed = $seeds[$seed_index];

        # Seed the random number generator from the string seed
        seed_rng($seed);

        #Calculate the offset for this seed's address range
        my $seed_offset = $address_space_per_seed * $seed_index;
        my $current_address = $network_bigint + $seed_offset;
        my $addresses_used = Math::BigInt->new(0);

        print "Seed: $seed\n";

        foreach my $new_prefix_length (@prefix_lengths) {
            # Calculate the block size (number of addresses) from the prefix length
            my $block_size_bigint = cidr_size($new_prefix_length);

            # Calculate the maximum possible offset for this block. Important to calculate this based on how many
            # blocks are used.
            my $max_offset = $address_space_per_seed - $block_size_bigint;

            # Check if we have enough addresses remaining in this seed's space and can place an offset
            if ($max_offset < 0 ) {
                warn "Not enough addresses remaining in this seed's space for a / $new_prefix_length block. Skipping.";
                next;
            }

            # Generate a random offset (between 0 and $max_offset)
            my $random_offset = Math::BigInt->new(int(rand($max_offset->as_number())));

            # Apply the random offset to the seed_offset to determine the final block start
            my $block_start_address = $network_bigint + $seed_offset + $random_offset;

            # Convert the block start address back to IPv6
            my $start_ip = bigint_to_ipv6($block_start_address);

            #Output the new CIDR (use the specified prefix length)
            print "  $start_ip/$new_prefix_length\n";

            #Advance the current address and number of addresses used. We no longer advance the
            #address on each loop.
            $addresses_used += $block_size_bigint + $random_offset;
        }
    }
}
