function A=window(varargin)
%Disjoin B image in n rows and m columns and permit to view the part in a (row) and b (column) position.
%There are two possibilities: with 5 or 6 inputs to window function.
%For example "window(B,2,3,1,2)" loads B image, disjoins it in a matrix with 2 rows and 3 columns and displays the part of image in first row and second column.
%"window(B,3,2,1,2,V)" with V is a vector with 3 elements (beacause 3 is the second input). I.e. V=[0.7 0.1 0.2].
%In this case window loads B image, disjoins it in a matrix with 3 rows and 2 columns and displays the part of image in first row and second column with 70% of width.

%case with there is a vector in input
if nargin==6
    B=varargin{1};
    n=varargin{2};
    m=varargin{3};
    a=varargin{4};
    b=varargin{5};
    V=varargin{6};

    %check if a and b parameters are propers
    if (a>n || b>m)
        disp('Error: that part of image does not exist');

        %check if V length is proper
    else if max(size(V))~=n
            disp('Error: vector length is wrong');

            %check if sum of V elements is 1
        else
            sum=0;
            for i=1:n
                sum=sum+V(i);
            end
            sum=chop(sum,2);
            if sum~=1
                disp('Error: sum of V elements is not 1');

                %set the start point and dimensions of the window considering n and m parameters
            else
                %set dimensions of the window
                length=size(B,2);
                width=size(B,1);
                o=round(width*V(a));
                v=round(length/m);

                %set the start point
                PIN=sumvect(V,a);
                c=round(width*PIN);
                d=(b-1)*v;

                %copy the image pixel-to-pixel
                A=B(1+c:min([c+o size(B,1)]),d+1:min([d+v size(B,2)]));
            end;
        end;
    end

    %case without a vector in input
else if nargin==5
        B=varargin{1};
        n=varargin{2};
        m=varargin{3};
        a=varargin{4};
        b=varargin{5};

        %check if a and b parameters are propers
        if (a>n || b>m)
            disp('Error: that part of image does not exist!');
        else

            %set dimensions of the window
            length=size(B,2);
            width=size(B,1);
            o=round(width/n);
            v=round(length/m);

            %set the start point
            c=(a-1)*o;
            d=(b-1)*v;

            %copy the image pixel-to-pixel
            A=B(1+c:min([c+o size(B,1)]),d+1:min([d+v size(B,2)]));
        end

        %if in input there are different values to 5 or 6, this give an error
    else disp('Error: unexpected inputs');
    end;
end