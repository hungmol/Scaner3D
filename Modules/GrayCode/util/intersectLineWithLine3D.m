function p = intersectLineWithLine3D(q1,v1,q2,v2)
    q12 = q1 - q2;
    v1b = v1.^2;
    v2b = v2.^2;
    v1v2 = v1.*v2;
    q12v1 = q12.*v1;
    q12v2 = q12.*v2;
    
    v1_dot_v1 = sum(v1b);
    v2_dot_v2 = sum(v2b);
    v1_dot_v2 = sum(v1v2);
    q12_dot_v1 = sum(q12v1);
    q12_dot_v2 = sum(q12v2);
    
	% Calculate scale factors.
	denom = v1_dot_v1.*v2_dot_v2 - v1_dot_v2.*v1_dot_v2;
	s =  (v1_dot_v2./denom).*q12_dot_v2 - (v2_dot_v2./denom).*q12_dot_v1;
	t = -(v1_dot_v2./denom).*q12_dot_v1 + (v1_dot_v1./denom).*q12_dot_v2;

	% Evaluate closest point.
    p = ((q1+repmat(s,3,1).*v1) + (q2 + repmat(t,3,1).*v2))/2;