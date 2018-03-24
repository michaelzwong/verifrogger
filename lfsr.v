// This module returns a random 13 bit number.
module LFSR
(
  input clock,
  input reset,
  output [12:0] rnd
);

// The tap locations for a 13 bit number
wire feedback = random[12] ^ random[3] ^ random[2] ^ random[0];

reg [12:0] random, random_next, random_done;

// keeps track of the shifts
reg [3:0] count, count_next;

always @ (posedge clock or posedge reset)
begin
  if (reset)
    begin
    // A LFSR cannot have an all 0 state, thus reset to FF
    random <= 13'hF;
    count <= 0;
    end
  else
    begin
      random <= random_next;
      count <= count_next;
    end
  end

always @ (*)
  begin
    random_next = random; //default state stays the same
    count_next = count;

    random_next = {random[11:0], feedback}; //shift left the xor'd every posedge clock
    count_next = count + 1;

    if (count == 13)
      begin
        count = 0;
        random_done = random; //assign the random number to output after 13 shifts
      end
    end


assign rnd = random_done;

endmodule
