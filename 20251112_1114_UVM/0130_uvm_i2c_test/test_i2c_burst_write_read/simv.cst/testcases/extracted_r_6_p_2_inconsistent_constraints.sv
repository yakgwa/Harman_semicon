class c_6_2;
    bit[7:0] req_addr = 8'haa;

    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (tb/tb_i2c.sv:46)
    {
       (req_addr == 8'hab);
    }
endclass

program p_6_2;
    c_6_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "1z00x10111xz0z101xz1xz0000xx1xxxzzxzxxxzzxzzzzxzxxzzzxxzzzzzzzxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
