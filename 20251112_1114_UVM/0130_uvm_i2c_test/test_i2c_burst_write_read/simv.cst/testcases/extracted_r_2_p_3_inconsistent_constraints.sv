class c_2_3;
    bit[7:0] req_addr = 8'h0;

    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (tb/tb_i2c.sv:43)
    {
       (req_addr == 8'haa);
    }
endclass

program p_2_3;
    c_2_3 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "1z00110x0zx11x0xx0zz010x011xzx1zzxzxxzzzzzzzzzxzzzxxzxzzzxxxzxxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
