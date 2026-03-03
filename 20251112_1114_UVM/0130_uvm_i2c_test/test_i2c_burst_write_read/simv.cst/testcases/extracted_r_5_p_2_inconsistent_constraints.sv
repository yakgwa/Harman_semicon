class c_5_2;
    bit[7:0] req_addr = 8'haa;

    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (tb/tb_i2c.sv:46)
    {
       (req_addr == 8'hab);
    }
endclass

program p_5_2;
    c_5_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "0x0z1xzxzzxx0z0zx1000100xx00x101zzxxzzxxxxxxxzxzzxxxxzzxzzzzzzxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
