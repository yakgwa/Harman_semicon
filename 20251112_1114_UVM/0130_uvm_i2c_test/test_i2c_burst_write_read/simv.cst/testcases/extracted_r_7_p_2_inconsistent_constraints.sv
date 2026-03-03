class c_7_2;
    bit[7:0] req_addr = 8'haa;

    constraint WITH_CONSTRAINT_this    // (constraint_mode = ON) (tb/tb_i2c.sv:46)
    {
       (req_addr == 8'hab);
    }
endclass

program p_7_2;
    c_7_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "z1zx1xxxx01xx1z11z1zzx1x001zz0zxzxxxzzzxxzxxzzxxxxzzzzzzxzxxzxxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
