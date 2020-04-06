/*
Autor: Jack0v
Sorting array Device by the "bubble" method.
Source video: https://youtu.be/cyX45Y37nOs 18:30
	!!!WARNING!!!
	This project was tested for EP4CE6E22C8 by QurtusII 9.1SP2.
	Before compiling, specify the pins of the your FPGA. Example:
	//(*chip_pin = "64"*) input anL
*/
/*
Автор: Jack0v
Устройство сортировки массива методом "пузырька".
Исходное видео: https://youtu.be/cyX45Y37nOs 18:30
	!!!ВНИМАНИЕ!!!
	Этот проект тестировался под EP4CE6E22C8 в QurtusII 9.1SP2.
	Перед компиляцией укажи выводы своей ПЛИС. Пример:
	//(*chip_pin = "64"*) input anL
*/
//(C) Jack0v, 2020
module Sort((*chip_pin = "00"*) output nTLQ,
				(*chip_pin = "00"*) input anL,
					(*chip_pin = "00"*) input C);

	//подавление дребезга
	wire LQ;
	Chatter Chatter(.Q(LQ), .aX(!anL), .C(C));

	//УУ
	wire INC_CTY, DEC_CTY, L_REG0Y, L_REG1Y, WRY, MXAY, R_TFY, S_TFY, R_TLY;
	CD CD(	//управляющие сигналы
			.INC_CTY(INC_CTY),
			.DEC_CTY(DEC_CTY),
			.L_REG0Y(L_REG0Y),
			.L_REG1Y(L_REG1Y),
			.WRY(WRY),
			.MXAY(MXAY),
			.R_TFY(R_TFY),
			.S_TFY(S_TFY),
			.R_TLY(R_TLY),
				//осведомительные сигналы
				.TL(TLQ),
				.REG0GrREG1(REG0Q > REG1Q),
				.CTEq15(CTQ == 4'd15),
				.TF(TFQ),
					.C(C));
	
	reg DLQ, TLQ, TFQ; reg [3:0]CTQ; reg [7:0]REG0Q, REG1Q;
	always @(posedge C)
	begin
		DLQ <= LQ;
		//Т запуска
		if(R_TLY) begin TLQ <= 1'd0; end
			else begin if(LQ & !DLQ) begin TLQ <= 1'd1; end end

		//СЧ адреса
		if(INC_CTY) begin CTQ <= CTQ + 1'd1; end
			else
			begin
				if(DEC_CTY) begin CTQ <= CTQ - 1'd1; end
			end
		
		//Регистры
		if(L_REG0Y) begin REG0Q <= RAMQ; end
		if(L_REG1Y) begin REG1Q <= RAMQ; end
		
		//Т флага
		if(R_TFY) begin TFQ <= 0; end
			else
			begin
				if(S_TFY) begin TFQ <= 1'd1; end
			end
	end
	assign nTLQ = !TLQ;
	
	wire [7:0]RAMQ;
	RAM RAM(.q(RAMQ), .address(CTQ), .data(MXAY? REG1Q : REG0Q), .wren(WRY), .clock(C));
endmodule	

module Chatter(output reg Q, input aX, input C);
	reg X;
	reg [15:0]CTQ;
	always @(posedge C)
	begin
		X <= aX;
		if(X & ~&CTQ)
		begin
			CTQ <= CTQ + 1'd1;
		end	else
			begin
				if(!X & |CTQ)
				begin
					CTQ <= CTQ - 1'd1;
				end
			end
		if(&CTQ)
		begin
			Q <= 1'd1;
		end	else
			begin
				if(~|CTQ)
				begin
					Q <= 0;
				end
			end
	end
endmodule

module CD(	//управляющие сигналы
			output reg INC_CTY,
			output reg DEC_CTY,
			output reg L_REG0Y,
			output reg L_REG1Y,
			output reg WRY,
			output reg MXAY,
			output reg R_TFY,
			output reg S_TFY,
			output reg R_TLY,
				//осведомительные сигналы
				input TL,
				input REG0GrREG1,
				input CTEq15,
				input TF,
					input C);

	parameter 	a0 = 0, a1 = 1, a2 = 2, a3 = 3,
				a4 = 4, a5 = 5, a6 = 6, a7 = 7,
				a8 = 8, a15=15;
	
	reg [3:0]aY;
	reg [3:0]aQ;
	always @(posedge C) begin aQ <= aY; end
	
	always @*
	begin
		case(aQ)
			a0:
			begin
				if(!TL)
				begin
					aY = a0;
					INC_CTY = 1'd0;
					DEC_CTY = 1'd0;
					L_REG0Y = 1'd0;
					L_REG1Y = 1'd0;
					WRY		= 1'd0;
					MXAY	= 1'd0;
					R_TFY	= 1'd0;
					S_TFY	= 1'd0;
					R_TLY	= 1'd0;
				end
					else
					begin
						if(TL)
						begin
							aY = a1;
							INC_CTY = 1'd1;
							DEC_CTY = 1'd0;
							L_REG0Y = 1'd1;
							L_REG1Y = 1'd0;
							WRY		= 1'd0;
							MXAY	= 1'd0;
							R_TFY	= 1'd0;
							S_TFY	= 1'd0;
							R_TLY	= 1'd0;
						end
							else
							begin
								aY = a15;
								INC_CTY = 1'd0;
								DEC_CTY = 1'd0;
								L_REG0Y = 1'd0;
								L_REG1Y = 1'd0;
								WRY		= 1'd0;
								MXAY	= 1'd0;
								R_TFY	= 1'd0;
								S_TFY	= 1'd0;
								R_TLY	= 1'd0;
							end
					end
			
			end
			a1:
			begin
				aY = a2;
				INC_CTY = 1'd0;
				DEC_CTY = 1'd0;
				L_REG0Y = 1'd0;
				L_REG1Y = 1'd0;
				WRY		= 1'd0;
				MXAY	= 1'd0;
				R_TFY	= 1'd0;
				S_TFY	= 1'd0;
				R_TLY	= 1'd0;
			end
			a2:
			begin
				aY = a3;
				INC_CTY = 1'd0;
				DEC_CTY = 1'd0;
				L_REG0Y = 1'd0;
				L_REG1Y = 1'd1;
				WRY		= 1'd0;
				MXAY	= 1'd0;
				R_TFY	= 1'd0;
				S_TFY	= 1'd0;
				R_TLY	= 1'd0;
			end
			a3:
			begin
				if(REG0GrREG1)
				begin
					aY = a6;
					INC_CTY = 1'd0;
					DEC_CTY = 1'd1;
					L_REG0Y = 1'd0;
					L_REG1Y = 1'd0;
					WRY		= 1'd1;
					MXAY	= 1'd0;
					R_TFY	= 1'd0;
					S_TFY	= 1'd0;
					R_TLY	= 1'd0;
				end
					else
					begin
						if(!REG0GrREG1 & !CTEq15)
						begin
							aY = a1;
							INC_CTY = 1'd1;
							DEC_CTY = 1'd0;
							L_REG0Y = 1'd1;
							L_REG1Y = 1'd0;
							WRY		= 1'd0;
							MXAY	= 1'd0;
							R_TFY	= 1'd0;
							S_TFY	= 1'd0;
							R_TLY	= 1'd0;
						end
							else
							begin
								if(!REG0GrREG1 & CTEq15 & !TF)
								begin
									aY = a0;
									INC_CTY = 1'd1;
									DEC_CTY = 1'd0;
									L_REG0Y = 1'd0;
									L_REG1Y = 1'd0;
									WRY		= 1'd0;
									MXAY	= 1'd0;
									R_TFY	= 1'd0;
									S_TFY	= 1'd0;
									R_TLY	= 1'd1;
								end
									else
									begin
										if(!REG0GrREG1 & CTEq15 & TF)
										begin
											aY = a4;
											INC_CTY = 1'd1;
											DEC_CTY = 1'd0;
											L_REG0Y = 1'd0;
											L_REG1Y = 1'd0;
											WRY		= 1'd0;
											MXAY	= 1'd0;
											R_TFY	= 1'd1;
											S_TFY	= 1'd0;
											R_TLY	= 1'd0;											
										end
											else
											begin
												aY = a15;
												INC_CTY = 1'd0;
												DEC_CTY = 1'd0;
												L_REG0Y = 1'd0;
												L_REG1Y = 1'd0;
												WRY		= 1'd0;
												MXAY	= 1'd0;
												R_TFY	= 1'd0;
												S_TFY	= 1'd0;
												R_TLY	= 1'd0;
											end									
									end
							end
					end
			end
			a4:
			begin
				aY = a5;
				INC_CTY = 1'd0;
				DEC_CTY = 1'd0;
				L_REG0Y = 1'd0;
				L_REG1Y = 1'd0;
				WRY		= 1'd0;
				MXAY	= 1'd0;
				R_TFY	= 1'd0;
				S_TFY	= 1'd0;
				R_TLY	= 1'd0;
			end
			a5:
			begin
				aY = a1;
				INC_CTY = 1'd1;
				DEC_CTY = 1'd0;
				L_REG0Y = 1'd1;
				L_REG1Y = 1'd0;
				WRY		= 1'd0;
				MXAY	= 1'd0;
				R_TFY	= 1'd0;
				S_TFY	= 1'd0;
				R_TLY	= 1'd0;
			end
			a6:
			begin
				aY = a7;
				INC_CTY = 1'd1;
				DEC_CTY = 1'd0;
				L_REG0Y = 1'd0;
				L_REG1Y = 1'd0;
				WRY		= 1'd1;
				MXAY	= 1'd1;
				R_TFY	= 1'd0;
				S_TFY	= 1'd1;
				R_TLY	= 1'd0;
			end
			a7:
			begin
				aY = a8;
				INC_CTY = 1'd0;
				DEC_CTY = 1'd0;
				L_REG0Y = 1'd0;
				L_REG1Y = 1'd0;
				WRY		= 1'd0;
				MXAY	= 1'd0;
				R_TFY	= 1'd0;
				S_TFY	= 1'd0;
				R_TLY	= 1'd0;
			end
			a8:
			begin
				if(!CTEq15)
				begin
					aY = a1;
					INC_CTY = 1'd1;
					DEC_CTY = 1'd0;
					L_REG0Y = 1'd1;
					L_REG1Y = 1'd0;
					WRY		= 1'd0;
					MXAY	= 1'd0;
					R_TFY	= 1'd0;
					S_TFY	= 1'd0;
					R_TLY	= 1'd0;
				end
					else
					begin
						if(CTEq15)
						begin
						aY = a4;
						INC_CTY = 1'd1;
						DEC_CTY = 1'd0;
						L_REG0Y = 1'd0;
						L_REG1Y = 1'd0;
						WRY		= 1'd0;
						MXAY	= 1'd0;
						R_TFY	= 1'd0;
						S_TFY	= 1'd0;
						R_TLY	= 1'd0;
						end
							else
							begin
								aY = a15;
								INC_CTY = 1'd0;
								DEC_CTY = 1'd0;
								L_REG0Y = 1'd0;
								L_REG1Y = 1'd0;
								WRY		= 1'd0;
								MXAY	= 1'd0;
								R_TFY	= 1'd0;
								S_TFY	= 1'd0;
								R_TLY	= 1'd0;
							end
					end
			end
			a15:
			begin
				aY = a0;
				INC_CTY = 1'd0;
				DEC_CTY = 1'd0;
				L_REG0Y = 1'd0;
				L_REG1Y = 1'd0;
				WRY		= 1'd0;
				MXAY	= 1'd0;
				R_TFY	= 1'd0;
				S_TFY	= 1'd0;
				R_TLY	= 1'd0;
			end
			default:
			begin
				aY = a0;
				INC_CTY = 1'd0;
				DEC_CTY = 1'd0;
				L_REG0Y = 1'd0;
				L_REG1Y = 1'd0;
				WRY		= 1'd0;
				MXAY	= 1'd0;
				R_TFY	= 1'd0;
				S_TFY	= 1'd0;
				R_TLY	= 1'd0;
			end
		endcase
	end
endmodule