module FA (
    input a, b, cin,
    output sum, cout
);
    assign cout = (a&b) | (a^b)&cin;
    assign sum = a^b^cin;
endmodule