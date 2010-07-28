function xeng_conj_fix_init(blk, varargin)
% Initialize and configure the windowed CASPER X Engine with configurable output demux.
%
%n_bits_in is size of a component of a complex number.



% Declare any default values for arguments you might like.
defaults = {'n_ants', 8, 'n_bits_in', 4, ...
    'demux_factor', 4};
if same_state(blk, 'defaults', defaults, varargin{:}), return, end
check_mask_type(blk, 'xeng_conj_fix');
munge_block(blk, varargin{:});

%fprintf('starting variables processing\n');

n_ants = get_var('n_ants', 'defaults', defaults, varargin{:});
n_bits_in = get_var('n_bits_in', 'defaults', defaults, varargin{:});
demux_factor = get_var('demux_factor', 'defaults', defaults, varargin{:});

n_taps = floor(n_ants/2) + 1;
n_elements = demux_factor*(nchoosek(n_ants, 2) + n_ants);
elements_bits = ceil(log2(n_elements));
pivot_point = demux_factor*(n_taps*n_ants*3/4);


%fprintf('variables all done\n');

% Begin redrawing
%================

delete_lines(blk);


% Add Misc static blocks
reuse_block(blk, 'acc', 'built-in/inport','Position', [15,303,45,317]);
reuse_block(blk, 'valid', 'built-in/inport','Position', [15,100,45,114]);
reuse_block(blk, 'sync', 'built-in/inport','Position', [15,150,45,164]);


reuse_block(blk, 'pos_cnt', 'xbsIndex_r4/Counter', 'Position', [135,196,185,249],...
		'cnt_type','Count Limited',...
		'cnt_to',sprintf('%d',n_elements-1),...
		'n_bits',sprintf('%d',elements_bits),...
		'en','on',...
		'rst','on');

reuse_block(blk, 'pivot_point', 'xbsIndex_r4/Constant', 'Position', [135,261,185,279],...
		'const',sprintf('%d',pivot_point),...
		'bin_pt','0',...
		'n_bits',sprintf('%d',elements_bits),...		
		'arith_type','Unsigned');

reuse_block(blk, 'pivot', 'xbsIndex_r4/Relational', 'Position', [235,227,290,283],...
		'Latency','1',...
		'Mode','a>=b');

reuse_block(blk, 'sel_conj', 'xbsIndex_r4/Mux', 'Position', [590,242,615,308],...
		'inputs','2',...
		'Latency','1');


reuse_block(blk, 'delay1', 'xbsIndex_r4/Delay', 'Position', [250,298,280,322],...
		'reg_retiming','on',...
		'Latency','1');
reuse_block(blk, 'delay2', 'xbsIndex_r4/Delay', 'Position', [250,100,280,114],...
		'reg_retiming','on',...
		'Latency','1');
reuse_block(blk, 'delay3', 'xbsIndex_r4/Delay', 'Position', [250,150,280,164],...
		'reg_retiming','on',...
		'Latency','1');
reuse_block(blk, 'delay4', 'xbsIndex_r4/Delay', 'Position', [585,100,615,114],...
		'reg_retiming','on',...
		'Latency','1');
reuse_block(blk, 'delay5', 'xbsIndex_r4/Delay', 'Position', [585,150,615,164],...
		'reg_retiming','on',...
		'Latency','1');

		
% Set output port positions
reuse_block(blk, 'acc_out', 'built-in/outport','Position', [630,268,660,282]);
reuse_block(blk, 'valid_out', 'built-in/outport','Position', [630,100,660,114]);
reuse_block(blk, 'sync_out', 'built-in/outport','Position', [630,150,660,164]);


% Add Static lines
%=================
add_line(blk, 'acc/1', 'delay1/1', 'autorouting', 'on');
add_line(blk, 'valid/1', 'delay2/1', 'autorouting', 'on');
add_line(blk, 'valid/1', 'pos_cnt/2', 'autorouting', 'on');
add_line(blk, 'sync/1', 'delay3/1', 'autorouting', 'on');
add_line(blk, 'sync/1', 'pos_cnt/1', 'autorouting', 'on');
add_line(blk, 'delay2/1', 'delay4/1', 'autorouting', 'on');
add_line(blk, 'delay3/1', 'delay5/1', 'autorouting', 'on');
add_line(blk, 'delay4/1', 'valid_out/1', 'autorouting', 'on');
add_line(blk, 'delay5/1', 'sync_out/1', 'autorouting', 'on');
add_line(blk, 'pos_cnt/1', 'pivot/1', 'autorouting', 'on');
add_line(blk, 'pivot_point/1', 'pivot/2', 'autorouting', 'on');
add_line(blk, 'pivot/1', 'sel_conj/1', 'autorouting', 'on');
add_line(blk, 'delay1/1', 'sel_conj/2', 'autorouting', 'on');
add_line(blk, 'sel_conj/1', 'acc_out/1', 'autorouting', 'on');


%REDRAW DYNAMIC PARTS
switch demux_factor
case {1,2},
	n_unpacks = 2^(2-log2(demux_factor));
	%fprintf('n_unpacks=%d\n',n_unpacks);
	
	reuse_block(blk, 'remux', 'xbsIndex_r4/Concat',...
	'num_inputs', sprintf('%d',n_unpacks),...
       	'Position', [550,250+70*n_unpacks/2,590,280+70*n_unpacks/2]);
	
	add_line(blk, 'remux/1', 'sel_conj/3', 'autorouting', 'on');

    for n_unpack=1:n_unpacks,
        %fprintf('n_unpack=%d\n',n_unpack);
        reuse_block(blk, sprintf('slice%d',n_unpack), 'xbsIndex_r4/Slice', ...
	'Position', [310,n_unpack*70+234,330,n_unpack*70+246],...
	'mode','Lower Bit Location + Width',...
	'base0','LSB of Input',...
	'bit0',sprintf('%d',2*n_bits_in*(n_unpacks-n_unpack)),...
	'nbits',sprintf('%d',n_bits_in*2));
	
	reuse_block(blk, sprintf('unpack%d',n_unpack), 'casper_library/Misc/c_to_ri',...
       	'Position', [360,219+70*n_unpack,400,261+70*n_unpack],...
	'bin_pt','0',...
	'n_bits',sprintf('%d',n_bits_in));
	
	reuse_block(blk, sprintf('negate%d',n_unpack), 'xbsIndex_r4/Negate',...
       	'Position', [425,236+70*n_unpack,455,264+70*n_unpack],...
	'precision','User Defined',...
	'arith_type','Signed  (2''s comp)',...
	'n_bits',sprintf('%d',n_bits_in),...		
	'bin_pt','0',...
	'Latency','0');

	reuse_block(blk, sprintf('repack%d',n_unpack), 'casper_library/Misc/ri_to_c',...
       	'Position', [480,219+70*n_unpack,520,261+70*n_unpack]);


	add_line(blk, 'delay1/1', sprintf('slice%d/1',n_unpack),'autorouting', 'on');  
	add_line(blk, sprintf('slice%d/1',n_unpack), sprintf('unpack%d/1',n_unpack), 'autorouting', 'on');
	add_line(blk, sprintf('unpack%d/1',n_unpack), sprintf('repack%d/1',n_unpack), 'autorouting', 'on');
	add_line(blk, sprintf('unpack%d/2',n_unpack), sprintf('negate%d/1',n_unpack), 'autorouting', 'on');
	add_line(blk, sprintf('negate%d/1',n_unpack), sprintf('repack%d/2',n_unpack), 'autorouting', 'on');
	add_line(blk, sprintf('repack%d/1',n_unpack), sprintf('remux/%d',n_unpack), 'autorouting', 'on');
	end


case 4,
	reuse_block(blk, 'negate', 'xbsIndex_r4/Negate', 'Position', [425,306,455,334],...
	'precision','User Defined',...
	'arith_type','Signed  (2''s comp)',...
	'n_bits',sprintf('%d',n_bits_in),...		
	'bin_pt','0',...
	'Latency','0');

	reuse_block(blk, 'unpack', 'casper_library/Misc/c_to_ri', 'Position', [360,289,400,331],...
	'bin_pt','0',...
	'n_bits',sprintf('%d',n_bits_in));
	
	reuse_block(blk, 'repack', 'casper_library/Misc/ri_to_c', 'Position', [480,289,520,331]);
	
	add_line(blk, 'unpack/1', 'repack/1', 'autorouting', 'on');
	add_line(blk, 'unpack/2', 'negate/1', 'autorouting', 'on');
	add_line(blk, 'negate/1', 'repack/2', 'autorouting', 'on');
	add_line(blk, 'repack/1', 'sel_conj/3', 'autorouting', 'on');
	add_line(blk, 'delay1/1', 'unpack/1', 'autorouting', 'on');



case 8,
	reuse_block(blk, 'negate', 'xbsIndex_r4/Negate', 'Position', [390,348,415,373],...
	'precision','User Defined',...
	'arith_type','Signed  (2''s comp)',...
	'n_bits',sprintf('%d',n_bits_in),...		
	'bin_pt','0',...
	'Latency','0');

	reuse_block(blk, 'reint_in', 'xbsIndex_r4/Reinterpret', 'Position', [335,351,365,369],...
	'force_arith_type','on',...
	'arith_type','Signed  (2''s comp)',...
	'force_bin_pt','on',...
	'bin_pt','0');

	reuse_block(blk, 'reint_out', 'xbsIndex_r4/Reinterpret', 'Position', [440,351,460,369],...
	'force_arith_type','on',...
	'arith_type','Unsigned',...
	'force_bin_pt','on',...
	'bin_pt','0');

	reuse_block(blk, 'slice', 'xbsIndex_r4/Slice', ...
	'Position', [370,299,395,311],...
	'mode','Lower Bit Location + Width',...
	'base0','LSB of Input',...
	'bit0','0',...
	'nbits','1');

    reuse_block(blk, 'delay6', 'xbsIndex_r4/Delay', 'Position', [250,283,280,297],...
		'reg_retiming','on',...
		'Latency','1');
	
	reuse_block(blk, 'imag_sel', 'xbsIndex_r4/Mux', 'Position', [510,292,535,358],...
		'inputs','2',...
		'Latency','0');

	add_line(blk, 'pos_cnt/1', 'delay6/1', 'autorouting', 'on');
    add_line(blk, 'delay6/1', 'slice/1', 'autorouting', 'on');
	add_line(blk, 'delay1/1', 'reint_in/1', 'autorouting', 'on');
	add_line(blk, 'reint_in/1', 'negate/1','autorouting', 'on');
	add_line(blk, 'slice/1', 'imag_sel/1', 'autorouting', 'on');
	add_line(blk, 'delay1/1', 'imag_sel/2', 'autorouting', 'on');
	add_line(blk, 'negate/1', 'reint_out/1', 'autorouting', 'on');
	add_line(blk, 'reint_out/1', 'imag_sel/3', 'autorouting', 'on');
	add_line(blk, 'imag_sel/1', 'sel_conj/3', 'autorouting', 'on');


otherwise,
	errordlg('Demux factor for xeng_conj_fix must be either 1, 2, 4 or 8.');
	error('Demux factor for xeng_conj_fix must be either 1, 2, 4 or 8.');	
end

clean_blocks(blk);

fmtstr = sprintf('num_ants=%d',n_ants);
set_param(gcb, 'AttributesFormatString', fmtstr);

save_state(blk, 'defaults', defaults, varargin{:});

