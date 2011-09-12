function gitInfo=getGitInfo()
% Get information about the Git repository in the current directory, including: 
%          - branch name of the current Git Repo 
%          -Git SHA1 HASH of the most recent commit
%          -url of corresponding remote repository, if one exists
%
% The function first checks to see if a .git/ directory is present. If so it
% reads the .git/HEAD file to identify the branch name and then it looks up
% the corresponding commit.
%
% It then reads the .git/config file to find out the url of the
% corresponding remote repository. This is all stored in a gitInfo struct.
%
% Note this uses only file information, it makes no external program 
% calls at all. 
%
% This function must be in the base directory of the git repository
%
% Released under an MIT license.
%
% Andrew Leifer
% Harvard University
% Program in Biophysics, Center for Brain Science, 
% and Department of Physics
% leifer@fas.harvard.edu
% 12 September 2011

 gitInfo=[];
if ~exist('.git','file') || ~exist('.git/HEAD','file')
    %Git is not present
    return
end



%Read in the HEAD information, this will tell us the location of the file
%containing the SHA1
text=fileread('.git/HEAD');
parsed=textscan(text,'%s');

if ~strcmp(parsed{1}{1},'ref:') || ~length(parsed{1})>1
        %the HEAD is not in the expected format.
        %give up
        return
end

path=parsed{1}{2};
[pathstr, name, ext]=fileparts(path);
branchName=name;

%save branchname
gitInfo.branch=branchName;


%Read in SHA1
SHA1text=fileread(fullfile(['.git/' pathstr],[name ext]));
SHA1=textscan(SHA1text,'%s');
gitInfo.hash=SHA1{1}{1};


%Read in config file
config=fileread('.git/config');
%Find everything space delimited
temp=textscan(config,'%s','delimiter','\n');
lines=temp{1};

remote='';
%Lets find the name of the remote corresponding to our branchName
for k=1:length(lines)
    
    %Are we at the section describing our branch?
    if strcmp(lines{k},['[branch "' branchName '"]'])
        m=k+1;
        %While we haven't run out of lines
        %And while we haven't run into another section (which starts with
        % an open bracket)
        while (m<=length(lines) && ~strcmp(lines{m}(1),'[') )
            temp=textscan(lines{m},'%s');
            if length(temp{1})>=3
                if strcmp(temp{1}{1},'remote') && strcmp(temp{1}{2},'=')
                    %This is the line that tells us the name of the remote 
                    remote=temp{1}{3};
                end
            end
            
            m=m+1;
        end
        
        
    
    end
end
gitInfo.remote=remote;


url='';
%Find the remote's url
for k=1:length(lines)
    
    %Are we at the section describing our branch?
    if strcmp(lines{k},['[remote "' remote '"]'])
        m=k+1;
        %While we haven't run out of lines
        %And while we haven't run into another section (which starts with
        % an open bracket)
        while (m<=length(lines) && ~strcmp(lines{m}(1),'[') )
            temp=textscan(lines{m},'%s');
            if length(temp{1})>=3
                if strcmp(temp{1}{1},'url') && strcmp(temp{1}{2},'=')
                    %This is the line that tells us the name of the remote 
                    url=temp{1}{3};
                end
            end
            
            m=m+1;
        end
        
        
    
    end
end

gitInfo.url=url;