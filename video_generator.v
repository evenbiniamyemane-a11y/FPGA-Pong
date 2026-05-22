`timescale 1ns / 1ps

module video_generator (
    input wire visible,
    input wire clk,
    input wire btn_up,     
    input wire btn_down,
    input wire [9:0] x,
    input wire [9:0] y,
    output reg [3:0] r,    
    output reg [3:0] g,
    output reg [3:0] b
);

    parameter PADDLE_W = 10;
    parameter PADDLE_H = 60;
    parameter BALL_SIZE = 8;
    parameter SCREEN_W = 640;
    parameter SCREEN_H = 480;
    
    reg [9:0] ball_x = 320;
    reg [9:0] ball_y = 240;
    reg ball_dir_x = 1;
    reg ball_dir_y = 1;    

    reg [9:0] Ipaddle_y = 210; 
    reg [9:0] rpaddle_y = 210;

    // This triggers once per frame when the beam is at the top-left corner
    wire update_frame = (x == 799 && y == 524); 
    
    always @(posedge clk) begin
        if (update_frame) begin
            
            // Move the ball
            if (ball_dir_x) ball_x <= ball_x + 3; else ball_x <= ball_x - 3;
            if (ball_dir_y) ball_y <= ball_y + 3; else ball_y <= ball_y - 3;
            
            // Top and Bottom screen collisions
            if(ball_y < 5) begin
                ball_dir_y <= 1; 
            end
            else if(ball_y >= (SCREEN_H - BALL_SIZE - 5)) begin
                ball_dir_y <= 0;
            end
            
            // Left paddle control (Player)
            if(btn_up) begin
                if(Ipaddle_y > 4)
                    Ipaddle_y <= Ipaddle_y - 4;
                else
                    Ipaddle_y <= 0;
            end else if (btn_down) begin
                if(Ipaddle_y < (SCREEN_H - PADDLE_H - 4))
                    Ipaddle_y <= Ipaddle_y + 4;
                else
                    Ipaddle_y <= (SCREEN_H - PADDLE_H);
            end
            
            // Right paddle control (Simple AI)
            if(ball_y > rpaddle_y + (PADDLE_H/2) && rpaddle_y < (SCREEN_H - PADDLE_H))
                rpaddle_y <= rpaddle_y + 2;
            else if (rpaddle_y > 2)
                rpaddle_y <= rpaddle_y - 2;
                
            // Left paddle ball collision
            if (ball_x <= 20 && ball_y + BALL_SIZE >= Ipaddle_y && ball_y <= Ipaddle_y + PADDLE_H)
                ball_dir_x <= 1;
                
            // Right paddle ball collision
            if (ball_x >= (SCREEN_W - 20 - BALL_SIZE) && ball_y + BALL_SIZE >= rpaddle_y && ball_y <= rpaddle_y + PADDLE_H)
                ball_dir_x <= 0;
                
            // Reset ball if it goes off screen (Left or Right bounds)
            if (ball_x <= 2 || ball_x >= (SCREEN_W + 50)) begin
                ball_x <= 320;
                ball_y <= 240;
            end
        end
    end

    // Pixel drawing logic
    wire draw_ball = (x >= ball_x && x < ball_x + BALL_SIZE && y >= ball_y && y < ball_y + BALL_SIZE);
    wire draw_Ipaddle = (x >= 10 && x < 10 + PADDLE_W && y >= Ipaddle_y && y < Ipaddle_y + PADDLE_H);
    wire draw_rpaddle = (x >= SCREEN_W - 20 && x < SCREEN_W - 20 + PADDLE_W && y >= rpaddle_y && y < rpaddle_y + PADDLE_H);
    
    // Color Output Generator
    always @(*) begin
        if(!visible) begin
            r = 4'h0; g = 4'h0; b = 4'h0;
        end else if (draw_ball || draw_Ipaddle || draw_rpaddle) begin
            r = 4'hF; g = 4'hF; b = 4'hF; // Draw objects as white
        end else begin
            r = 4'h0; g = 4'h0; b = 4'h1; // Draw background as dark blue
        end
    end

endmodule
