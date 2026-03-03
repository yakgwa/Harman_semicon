class c_1_3;
    bit[7:0] req_addr = 8'h0;

    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (tb/tb_i2c.sv:43)
    {
       (req_addr == 8'haa);
    }
endclass

program p_1_3;
    c_1_3 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "x0zzxz0z0z1z10110zzzzz011xxxz1xzxzxxxxxzxzzzxxzzxzzxxzxxzxxxxxzx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
