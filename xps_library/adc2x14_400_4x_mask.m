%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Center for Astronomy Signal Processing and Electronics Research           %
%   http://seti.ssl.berkeley.edu/casper/                                      %
%   Copyright (C) 2006 University of California, Berkeley                     %
%                                                                             %
%   This program is free software; you can redistribute it and/or modify      %
%   it under the terms of the GNU General Public License as published by      %
%   the Free Software Foundation; either version 2 of the License, or         %
%   (at your option) any later version.                                       %
%                                                                             %
%   This program is distributed in the hope that it will be useful,           %
%   but WITHOUT ANY WARRANTY; without even the implied warranty of            %
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             %
%   GNU General Public License for more details.                              %
%                                                                             %
%   You should have received a copy of the GNU General Public License along   %
%   with this program; if not, write to the Free Software Foundation, Inc.,   %
%   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.               %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myname = gcb; 
%set_param(myname, 'LinkStatus', 'inactive');

gateway_ins = find_system(gcb,'searchdepth',1,'FollowLinks', 'on','lookundermasks','all','masktype','Xilinx Gateway In Block');
for i =1:length(gateway_ins)
    gw = gateway_ins{i};
    if regexp(get_param(gw,'Name'),'(user_data_i0)$')
        toks = regexp(get_param(gw,'Name'),'(user_data_i0)$','tokens');
        set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(user_data_i1)$')
        toks = regexp(get_param(gw,'Name'),'(user_data_i1)$','tokens');
        set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(user_data_i2)$')
      toks = regexp(get_param(gw,'Name'),'(user_data_i2)$','tokens');
      set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(user_data_i3)$')
      toks = regexp(get_param(gw,'Name'),'(user_data_i3)$','tokens');
      set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));        
    elseif regexp(get_param(gw,'Name'),'(user_data_q0)$')
      toks = regexp(get_param(gw,'Name'),'(user_data_q0)$','tokens');
      set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(user_data_q1)$')
      toks = regexp(get_param(gw,'Name'),'(user_data_q1)$','tokens');
        set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(user_data_q2)$')
      toks = regexp(get_param(gw,'Name'),'(user_data_q2)$','tokens');
      set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(user_data_q3)$')
      toks = regexp(get_param(gw,'Name'),'(user_data_q3)$','tokens');
      set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(user_sync)$')
      toks = regexp(get_param(gw,'Name'),'(user_sync)$','tokens');
      set_param(gw,'Name',clear_name([gcb,'_',toks{1}{1}]));
    else
        error(['Unkown gateway name: ',gw]);
    end
end
