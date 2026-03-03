class c_8_2;
    bit[7:0] req_addr = 8'haa;

    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (tb/tb_i2c.sv:46)
    {
       (req_addr == 8'hab);
    }
endclass

program p_8_2;
    c_8_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "1100zzx11z1000z10z11xxzxxxx10010xxzzzxxxxzxxxxxzxzxxzxxxxzxxzzzz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
