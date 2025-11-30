`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/25 10:50:52
// Design Name: 
// Module Name: CBMP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// header file save & image file save

class CBMP;
    byte bmpHeader[54];
    byte bmpImgData[320*240*3];
    
    int fd; // file id(file discriptor)
    string fileName;
    
    function new(string fileName, string mode);
       open(fileName, mode);
    endfunction
    
    function int open(string fileName, string mode);
        fd = $fopen(fileName, mode);
        this.fileName = fileName;
        if(!fd) begin
            $display("[%s] file is open failed!", fileName);
        end else begin
            $display("[%s] file is opened!", fileName);    
        end
        return fd;
    endfunction
    
    function void close();
        $fclose(fd);
        $display("[%s] file is closed!", fileName);
    endfunction

    function int read();
        int size = 0;
        size = $fread(bmpHeader, fd);
        $display("[%s] bmpHeader is read! Header size : %0d", fileName, size);
        
        size = $fread(bmpImgData, fd);
        $display("[%s] bmpHeaer is read! Img data size : %0d", fileName, size);
        
    endfunction
    
    function int write(byte imgData[], int size);
        for(int i = 0; i < size; i++) begin
            $fwrite(fd,"%c", imgData[i]);
        end
    endfunction
    
    function void flush();
        $fflush(fd);
    endfunction
    
endclass
