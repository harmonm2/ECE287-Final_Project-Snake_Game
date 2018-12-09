module Snake(clk, rst, DAC_clk, VGA_R, VGA_G, VGA_B, VGA_Hsync, 
					VGA_Vsync, blank_n, KB_clk, data);

					
// variables
// clock and rest					
input clk, rst;
input KB_clk, data;


// snake direction
wire [4:0]direction;
wire reset;


// R, G, B values
output reg [7:0]VGA_R;
output reg [7:0]VGA_G;
output reg [7:0]VGA_B;


// VGA paramters
output VGA_Hsync;
output VGA_Vsync;
output DAC_clk;
output blank_n;


// x, y coordinate counter
wire [10:0]xCounter;
wire [10:0]yCounter;


// RGB
wire R;
wire G;
wire B;


// VGA clock update, and display
wire update;
wire VGA_clk;
wire displayArea;


// Snake
// Snake head
wire snakeHead;
reg snakeBody;
reg [9:0]xHead;
reg [9:0]yHead;


// Snake body
// X-values
reg [10:0] x, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15;
// Y-values
reg [10:0] y, y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15;

reg body1, body2, body3, body4, body5, body6,
		body7, body8, body9, body10, body11, body12,
		body13, body14, body15;

		
// Apple, apple coordinate, and apple count
// Apple count = # of apples eaten by snake
reg [9:0]appleCount;

reg [10:0]appleX,appleY;
reg [15:0]appleXCount, appleYCount;


// Border and game status
reg border;
reg game_over;
reg win_game;


// Use modules for keyboard input, VGA output, and clock changes
// kbInput and VGA_generator created by Ian Sweetland, Kristjan Jacobson, and Daniel Lovegrove
// https://www.instructables.com/id/Snake-on-an-FPGA-Verilog/ 
kbInput keyboard(KB_clk, data, direction, reset);
updateCLK clk_updateCLK(clk, update);
clk_reduce reduce(clk, VGA_clk);
VGA_generator generator(VGA_clk, VGA_Hsync, VGA_Vsync, DisplayArea, xCounter, yCounter, blank_n);


// Assign values
assign DAC_clk = VGA_clk;
assign snakeHead = (xCounter >= x && xCounter <= x+15 && yCounter >= y && yCounter <= y + 15); //assign snakeHead value
assign apple = (xCounter >= appleX + 5 && xCounter <= appleX + 15 && yCounter >= appleY + 5 && yCounter <= appleY + 15); //assign apple value


// Apple generation and direction
always@(posedge update)
begin
	if(rst == 0)
	begin	
		x <= 11'd320; 
		y <= 11'd240;		
	end
	else
	begin
		// Creates pseudo-random coordinates for apple x, y coordinates
		appleXCount <= ((appleXCount + 10'd75) % 10'd600);
		appleYCount <= ((appleYCount + 10'd75) % 9'd420);
					
		x1 <= x; y1 <= y;
		x2 <= x1; y2 <= y1;
		x3 <= x2; y3 <= y2;
		x4 <= x3; y4 <= y3;
		x5 <= x4; y5 <= y4;
		x6 <= x5; y6 <= y5;
		x7 <= x6; y7 <= y6;
		x8 <= x7; y8 <= y7;
		x9 <= x8; y9 <= y8;
		x10 <= x9; y10 <= y9;
		x11 <= x10; y11 <= y10;
		x12 <= x11; y12 <= y11;
		x13 <= x12; y13 <= y12;
		x14 <= x13; y14 <= y13;
		x15 <= x14; y15 <= y14;

			case(direction)
			// Up
			5'b00010: y <= y - 11'd20; 
			// Left
			5'b00100: x <= x - 11'd20; 
			// Down
			5'b01000: y <= y + 11'd20; 
			// Right
			5'b10000: x <= x + 11'd20; 
			endcase		
	end
end



// Border Creation
always @(posedge VGA_clk)
begin
	border <= (((xCounter >= 0) && (xCounter < 11) || (xCounter >= 630) && (xCounter < 641)) 
				|| ((yCounter >= 0) && (yCounter < 11) || (yCounter >= 470) && (yCounter < 481)));
end
//Assign colors to snake, apple, background, border
assign R = ((snakeHead || body1 || body2 || body3 || body4
					 || body5 || body6 || body7 || body8
					  || body9 || body10 || body11 || body12
					   || body13 || body14 || body15) || apple || game_over) && ~win_game;
assign G = (snakeHead || body1 || body2 || body3 || body4
					 || body5 || body6 || body7 || body8
					  || body9 || body10 || body11 || body12
					   || body13 || body14 || body15 || win_game) && ~game_over;
assign B = ((snakeHead || body1 || body2 || body3 || body4
					 || body5 || body6 || body7 || body8
					  || body9 || body10 || body11 || body12
					   || body13 || body14 || body15) || border) && (~game_over && ~win_game);
// VGA colors
always@(posedge VGA_clk)
begin
	VGA_R = {8{R}};
	VGA_G = {8{G}};
	VGA_B = {8{B}};
end


// Define values for snake and apple/ gaming specifics
initial
begin
	
	appleX = 9'd400;
	appleY = 8'd400;
	appleXCount = 9'd400;
	appleYCount = 8'd400;
	
	x = 11'd320; y = 11'd240;
	x1 = 11'd320; y1 = 11'd240;
	x2 = 11'd320; y2 = 11'd240;
	x3 = 11'd320; y3 = 11'd240;
	x4 = 11'd320; y4 = 11'd240;
	x5 = 11'd320; y5 = 11'd240;
	x6 = 11'd320; y6 = 11'd240;
	x7 = 11'd320; y7 = 11'd240;
	x8 = 11'd320; y8 = 11'd240;
	x9 = 11'd320; y9 = 11'd240;
	x10 = 11'd320; y10 = 11'd240;
	x11 = 11'd320; y11 = 11'd240;
	x12 = 11'd320; y12 = 11'd240;
	x13 = 11'd320; y13 = 11'd240;
	x14 = 11'd320; y14 = 11'd240;
	x15 = 11'd320; y15 = 11'd240;
end

// FSM for game 
always@(posedge VGA_clk)
begin
	if(rst == 0)
	begin
		appleX <= appleXCount;
		appleY <= appleYCount;
		
		body1 <= 0;
		body2 <= 0;
		body3 <= 0;
		body4 <= 0;
		body5 <= 0;
		body6 <= 0;
		body7 <= 0;
		body8 <= 0;
		body9 <= 0;
		body10 <= 0;
		body11 <= 0;
		body12 <= 0;
		body13 <= 0;
		body14 <= 0;
		body15 <= 0;
		
		win_game <= 0;
		game_over <= 0;
		appleCount <= 0;
	end
	else 
		begin
		// Snake respawn if apple is eaten of if apple spawns in snake
		if(snakeHead && apple || 
			 (apple &&(body1 || body2 || body3 || body4
					 || body5 || body6 || body7 || body8
					  || body9 || body10 || body11 || body12
					   || body13 || body14 || body15)))
		begin
			appleX <= appleXCount;
			appleY <= appleYCount;
			appleCount <= appleCount + 1;
		end
		
		// Respawn apple if in border buffer
		else if(apple && border)
		begin
			appleX <= appleXCount;
			appleY <= appleYCount;
		end
		
		// Collision detection, leads to game over screen
		else if(snakeHead && (body1 || body2 || body3 || body4
					 || body5 || body6 || body7 || body8
					  || body9 || body10 || body11 || body12
					   || body13 || body14 || body15 || border))
		begin
			game_over <= 1;
		end
		
		// Assigning values for snake body
		if(appleCount > 10'd0)
		begin			
			body1 <= blank_n &&(xCounter >= x1 && xCounter <= x1+15 && yCounter >= y1 && yCounter <= y1 +15);
		end
		if(appleCount > 10'd1)
		begin	
			body2 <= blank_n &&(xCounter >= x2 && xCounter <= x2+15 && yCounter >= y2 && yCounter <= y2 +15);
		end
		if(appleCount > 10'd2)
		begin		
			body3 <= (xCounter >= x3 && xCounter <= x3+15 && yCounter >= y3 && yCounter <= y3 +15);
		end
		if(appleCount > 10'd3)
		begin	
			body4 <= (xCounter >= x4 && xCounter <= x4+15 && yCounter >= y4 && yCounter <= y4 +15);
		end
		if(appleCount > 10'd4)
		begin			
			body5 <= (xCounter >= x5 && xCounter <= x5+15 && yCounter >= y5 && yCounter <= y5 +15);
		end
		if(appleCount > 10'd5)
		begin			
			body6 <= (xCounter >= x6 && xCounter <= x6+15 && yCounter >= y6 && yCounter <= y6 +15);
		end
		if(appleCount > 10'd6)
		begin			
			body7 <= (xCounter >= x7 && xCounter <= x7+15 && yCounter >= y7 && yCounter <= y7 +15);
		end
		if(appleCount > 10'd7)
		begin			
			body8 <= (xCounter >= x8 && xCounter <= x8+15 && yCounter >= y8 && yCounter <= y8 +15);
		end
		if(appleCount > 10'd8)
		begin			
			body9 <= (xCounter >= x9 && xCounter <= x9+15 && yCounter >= y9 && yCounter <= y9 +15);
		end
		if(appleCount > 10'd9)
		begin			
			body10 <= (xCounter >= x10 && xCounter <= x10+15 && yCounter >= y10 && yCounter <= y10 +15);
		end
		if(appleCount > 10'd10)
		begin			
			body11 <= (xCounter >= x11 && xCounter <= x11+15 && yCounter >= y11 && yCounter <= y11 +15);
		end
		if(appleCount > 10'd11)
		begin			
			body12 <= (xCounter >= x12 && xCounter <= x12+15 && yCounter >= y12 && yCounter <= y12 +15);
		end
		if(appleCount > 10'd12)
		begin			
			body13 <= (xCounter >= x13 && xCounter <= x13+15 && yCounter >= y13 && yCounter <= y13 +15);
		end
		if(appleCount > 10'd13)
		begin			
			body14 <= (xCounter >= x14 && xCounter <= x14+15 && yCounter >= y14 && yCounter <= y14 +15);
		end
		if(appleCount > 10'd14)
		begin			
			body15 <= (xCounter >= x15 && xCounter <= x15+15 && yCounter >= y15 && yCounter <= y15 +15);
		end
		
		// Check game status if 15 apples reached, game is won
		if(appleCount > 10'd15)
		begin
			win_game <= 1;
			if(snakeHead&&border)
				game_over <= 0;
		end
	end
end
endmodule


/////////////////////////////////////////////////////////////////// keyboard input
// kbInput and VGA_generator created by Ian Sweetland, Kristjan Jacobson, and Daniel Lovegrove
// https://www.instructables.com/id/Snake-on-an-FPGA-Verilog/ 
module kbInput(KB_clk, data, direction, reset);

	input KB_clk, data;
	output reg [4:0] direction;
	output reg reset = 0; 
	reg [7:0] code;
	reg [10:0]keyCode, previousCode;
	reg recordNext = 0;
	integer count = 0;

always@(negedge KB_clk)
	begin
		keyCode[count] = data;
		count = count + 1;			
		if(count == 11)
		begin
			if(previousCode == 8'hF0)
			begin
				code <= keyCode[8:1];
			end
			previousCode = keyCode[8:1];
			count = 0;
		end
	end
	
	always@(code)
	begin
		if(code == 8'h1D)
			direction = 5'b00010;
		else if(code == 8'h1C)
			direction = 5'b00100;
		else if(code == 8'h1B)
			direction = 5'b01000;
		else if(code == 8'h23)
			direction = 5'b10000;
		else if(code == 8'h5A)
			reset <= ~reset;
		else direction <= direction;
	end	
endmodule


/////////////////////////////////////////////////////////////////// VGA_generator to display using VGA
// kbInput and VGA_generator created by Ian Sweetland, Kristjan Jacobson, and Daniel Lovegrove
// https://www.instructables.com/id/Snake-on-an-FPGA-Verilog/ 
module VGA_generator(VGA_clk, VGA_Hsync, VGA_Vsync, DisplayArea, xCounter, yCounter, blank_n);
input VGA_clk;
output VGA_Hsync, VGA_Vsync, blank_n;
output reg DisplayArea;
output reg [9:0] xCounter;
output reg [9:0] yCounter;

reg HSync;
reg VSync;

integer HFront = 640;//640
integer hSync = 655;//655
integer HBack = 747;//747
integer maxH = 793;//793

integer VFront = 480;//480
integer vSync = 490;//490
integer VBack = 492;//492
integer maxV = 525;//525

always@(posedge VGA_clk)
begin
	if(xCounter === maxH)
		xCounter <= 0;
	else
		xCounter <= xCounter + 1;
end

always@(posedge VGA_clk)
begin
	if(xCounter == maxH)
	begin
		if(yCounter === maxV)
			yCounter <= 0;
		else
			yCounter <= yCounter +1;
	end
end

always@(posedge VGA_clk)
begin
	DisplayArea <= ((xCounter < HFront) && (yCounter < VFront));
end

always@(posedge VGA_clk)
begin
	HSync <= ((xCounter >= hSync) && (xCounter < HBack));
	VSync <= ((yCounter >= vSync) && (yCounter < VBack));
end

assign VGA_Vsync = ~VSync;
assign VGA_Hsync = ~HSync;
assign blank_n = DisplayArea;

endmodule


/////////////////////////////////////////////////////////////////// update clk to lower snake speed
module updateCLK(clk, update);
input clk;
output reg update;
reg[21:0]count;

always@(posedge clk)
begin
	count <= count + 1;
	if(count == 2500000)
	begin
		update <= ~update;
		count <= 0;
	end
end
endmodule


/////////////////////////////////////////////////////////////////// reduce clk from 50MHz to 25MHz
module clk_reduce(clk, VGA_clk);

	input clk;
	output reg VGA_clk;
	reg a;

	always@(posedge clk)
	begin
		a <= ~a; 
		VGA_clk <= a;
	end
endmodule



