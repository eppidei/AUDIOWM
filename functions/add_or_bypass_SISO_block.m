function add_or_bypass_SISO_block(type,subsys_name,block_name,block_params,inport_name,oport_name,library_name)

%%%%param struct 
%param.n_parmams param.name_str param.val_str
if (ischar(subsys_name)==0)
    error('subsys_name must be a string');
end
if (ischar(block_name)==0)
    error('block_name must be a string');
end
if (ischar(inport_name)==0)
    error('inport_name must be a string');
end
if (ischar(oport_name)==0)
    error('oport_name must be a string');
end
if (ischar(library_name)==0)
    error('library_name must be a string');
end

if (iscellstr(block_params.name_str)==0)
    
    error('param.name_str must be a cell array of strings');
end

if ( length(block_params.name_str)~=length(block_params.val_str) )
    
    error('The number of parameters must be equal to the number of values');
end
%%%%parameter creat
add_block_str=['add_block([library_name,''/'',block_name],bpath2,'];
for i=1:block_params.n_params
   
    if (i==block_params.n_params)
        add_block_str = [add_block_str,'block_params.name_str{',num2str(i),'}',',','block_params.val_str{',num2str(i),'}',');'];
    else
        add_block_str = [add_block_str,'block_params.name_str{',num2str(i),'}',',','block_params.val_str{',num2str(i),'}',','];
    end
    
end

if strcmp(type,'add')

   bpath = find_system(subsys_name,'Name',block_name);
   iport_h = find_system(subsys_name,'FindAll','on','type','block','Name',inport_name);
   oport_h = find_system(subsys_name,'FindAll','on','type','block','Name',oport_name);
   if isempty(bpath)
       bpath2=[subsys_name,['/',block_name]];
%    add_block([library_name,'/',block_name],bpath2,'N',num2str(WM.Sim.Codeword_length),'K',num2str(WM.Sim.Message_length));
eval(add_block_str);
   else
       bpath2=[subsys_name,['/',block_name]];
%        str=sprintf('%s',bpath{1});
%        warning('block %s already present',str);
delete_block(bpath);
eval(add_block_str);
   end
   line_h1 = find_system(subsys_name,'FindAll','on','type','line','SrcBlockHandle',iport_h);
    if isempty(line_h1)
        warning([block_name,' input line has been already removed']);
   else
       delete_line(line_h1);
   end
   
   line_h2 = find_system(subsys_name,'FindAll','on','type','line','DstBlockHandle',oport_h);
   if isempty(line_h2)
        warning([block_name,' output line has been already removed']);
   else
        delete_line(line_h2);
   end
   
   add_line(subsys_name,[inport_name,'/1'],[block_name,'/1']);
   add_line(subsys_name,[block_name,'/1'],[oport_name,'/1']);


elseif strcmp(type,'bypass')
    
     bpath = find_system(subsys_name,'Name',block_name);
   iport_h = find_system(subsys_name,'FindAll','on','type','block','Name',inport_name);
   oport_h = find_system(subsys_name,'FindAll','on','type','block','Name',oport_name);
  
   if isempty(bpath)
     warning([block_name,' block has been already removed']);
   else
      delete_block(bpath);
   end
   
   line_h1 = find_system(subsys_name,'FindAll','on','type','line','SrcBlockHandle',iport_h);
   if isempty(line_h1)
        warning([block_name,' input line has been already removed']);
   else
       delete_line(line_h1);
   end
   
   line_h2 = find_system(subsys_name,'FindAll','on','type','line','DstBlockHandle',oport_h);
   if isempty(line_h2)
        warning([block_name,'  output line has been already removed']);
   else
        delete_line(line_h2);
   end
   add_line(subsys_name,[inport_name,'/1'],[oport_name,'/1']);

else
    
    error('Unknown option %s allowed only add or bypass',type);
    
end

