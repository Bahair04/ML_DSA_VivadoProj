module top_wrapper(
    input   clk,
    input   rstn

);
// --- KeyGen 接口 ---
logic                       start_keygen;          
logic                       key_ready_keygen;      
logic                       done_keygen;           
logic           [255 : 0]   zeta_keygen;              

// --- Sign 接口 ---
logic                       start_sign;          
logic                       sign_ready;      
logic                       done_sign;
logic           [511 : 0]   mu;             // 64字节 预哈希消息
logic           [255 : 0]   rnd;            // 32字节 随机数

// --- Verify 接口---
logic                       start_verify;          // 启动标志
logic                       verify_ready;          // 准备标志
logic                       done_verify;           // 完成标志
logic                       verify_flag;
logic           [511 : 0]   mu_verify;              // 64字节 预哈希消息

ML_DSA_top u_ML_DSA_top(
	.clk              	( clk               ),
	.rstn             	( rstn              ),
	.start_keygen     	( start_keygen      ),
	.key_ready_keygen 	( key_ready_keygen  ),
	.done_keygen      	( done_keygen       ),
	.zeta_keygen      	( zeta_keygen       ),
	.start_sign       	( start_sign        ),
	.sign_ready       	( sign_ready        ),
	.done_sign        	( done_sign         ),
	.mu               	( mu                ),
	.rnd              	( rnd               ),
	.start_verify     	( start_verify      ),
	.verify_ready     	( verify_ready      ),
	.done_verify      	( done_verify       ),
	.verify_flag      	( verify_flag       ),
	.mu_verify        	( mu_verify         )
);


endmodule
