function infoDistributorManager(port_number)
% port_number: control channel port number

nserver = readParam('server_number');

parallel_handler(nserver);

parfor i = 1:nserver
  % start infoDistributor
  infoDistributor(port_number, i);
end


end
