function results=extract_recon_ensemble_simout(simout,N)
% Split a 42N-channel batch output into N ordinary result structs.

if isa(simout,'timeseries')
    t=simout.Time(:);y=squeeze(simout.Data);
else
    t=simout.time(:);y=squeeze(simout.signals.values);
end
if size(y,1)~=numel(t),y=y.';end
results=[];
for i=1:N
    yi=y(:,(i-1)*42+(1:42));
    r=struct();r.t=t;r.x=yi(:,1:6);r.force_terms=yi(:,7:15);
    r.M_0=yi(:,16:18);r.M_ifa=yi(:,19:21);r.M_hat_raw=yi(:,22:24);
    r.M_ifa_hat=yi(:,25:27);r.M_comp_raw=yi(:,28:30);
    r.M_comp=yi(:,31:33);r.M_c=yi(:,34:36);r.M_dist=yi(:,37:39);
    r.saturation_flag=yi(:,40:42);
    if i==1
        results=repmat(r,N,1);
    else
        results(i)=r;
    end
end
end
