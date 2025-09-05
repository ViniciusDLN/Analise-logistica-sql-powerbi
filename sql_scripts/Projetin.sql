

-- Visão geral da tabela

SELECT
	e.envio_id,
	a.nome_armazem,
	a.cidade,
	a.pais,
	e.transportadora,
	e.data_envio,
	e.data_entrega_estimada,
	e.status_envio,
	ROUND(e.custo_envio,2) AS custo_envio
FROM
	envios e
INNER JOIN armazens AS a ON e.armazem_origem_id = a.armazem_id -- Utilizei INNER JOIN para relacionar duas tabelas

-- armazéns e status_envio

WITH rotas AS -- Utilizei CTE, pois tem a melhor organização nos dados.
	(
	SELECT 
		a.nome_armazem AS nome_armazem,
		e.status_envio AS status_envio,
		(CASE WHEN e.status_envio = 'Em Rota' THEN 2
				 WHEN e.status_envio = 'Entregue' THEN 3
				 WHEN e.status_envio = 'Atrasado' THEN 1
				 WHEN e.status_envio = 'Cancelado' THEN 0 END) AS situacao
	FROM
		envios e	
	INNER JOIN armazens AS a ON e.armazem_origem_id = a.armazem_id -- Utilizei INNER JOIN para relacionar duas tabelas
	)
	SELECT
		nome_armazem,
		status_envio,
		COUNT(situacao) AS quantidade
	FROM
		rotas
	GROUP BY
		nome_armazem,
		status_envio

-- armazéns + transportadora e status_envio

WITH rotas AS
	(
	SELECT 
		a.nome_armazem AS nome_armazem,
		e.status_envio AS status_envio,
		e.transportadora AS transportadora,
		(CASE WHEN e.status_envio = 'Em Rota' THEN 2
				 WHEN e.status_envio = 'Entregue' THEN 3
				 WHEN e.status_envio = 'Atrasado' THEN 1
				 WHEN e.status_envio = 'Cancelado' THEN 0 END) AS situacao
	FROM
		envios e	
	INNER JOIN armazens AS a ON e.armazem_origem_id = a.armazem_id
	)
	SELECT
		nome_armazem,
		status_envio,
		transportadora,
		COUNT(situacao) AS quantidade
	FROM
		rotas
	GROUP BY
		nome_armazem,
		status_envio,
		transportadora


-- Transportadora e status_envio

WITH rotas AS
	(
	SELECT 
		e.transportadora AS transportadora,
		e.status_envio AS status_envio,
		(CASE WHEN e.status_envio = 'Em Rota' THEN 2
				 WHEN e.status_envio = 'Entregue' THEN 3
				 WHEN e.status_envio = 'Atrasado' THEN 1
				 WHEN e.status_envio = 'Cancelado' THEN 0 END) AS situacao
	FROM
		envios e	
	INNER JOIN armazens AS a ON e.armazem_origem_id = a.armazem_id
	)
	SELECT
		transportadora,
		status_envio,
		COUNT(situacao) AS quantidade
	FROM
		rotas
	GROUP BY
		transportadora,
		status_envio

-- Cidade e País status_envio

WITH rotas AS
	(
	SELECT 
		a.pais AS pais,
		a.cidade AS cidade,
		e.status_envio AS status_envio,
		(CASE WHEN e.status_envio = 'Em Rota' THEN 2
				 WHEN e.status_envio = 'Entregue' THEN 3
				 WHEN e.status_envio = 'Atrasado' THEN 1
				 WHEN e.status_envio = 'Cancelado' THEN 0 END) AS situacao
	FROM
		envios e	
	INNER JOIN armazens AS a ON e.armazem_origem_id = a.armazem_id
	)
	SELECT
		pais,
		cidade,
		status_envio,
		COUNT(situacao) AS quantidade
	FROM
		rotas
	GROUP BY
		pais,
		cidade,
		status_envio

-- Média de custo transportadora por país

SELECT
	a.pais,
	e.transportadora,
	ROUND(AVG(e.custo_envio),2) AS AVG_custo_envio
FROM
	envios e
INNER JOIN armazens AS a ON e.armazem_origem_id = a.armazem_id
GROUP BY
	e.transportadora,
	a.pais
ORDER BY
	a.pais,
	AVG_custo_envio DESC

-- Média de custo transportadora + cidade + país

SELECT
	a.pais,
	a.cidade,
	e.transportadora,
	ROUND(AVG(e.custo_envio),2) AS AVG_custo_envio
FROM
	envios e
INNER JOIN armazens AS a ON e.armazem_origem_id = a.armazem_id
GROUP BY
	e.transportadora,
	a.cidade,
	a.pais
ORDER BY
	a.pais,
	AVG_custo_envio DESC

-- Qual Mês teve mais atrasos

WITH mes AS
	(SELECT
	a.pais AS pais,
	e.transportadora AS transportadora,
	CASE WHEN e.data_envio LIKE '%01%' THEN 'Janeiro' -- CASE WHEN foi utilizado para mostrar os meses, pois estavam em formato de números.
		 WHEN e.data_envio LIKE '%02%' THEN 'Fevereiro'
		 WHEN e.data_envio LIKE '%03%' THEN 'Março'
		 WHEN e.data_envio LIKE '%04%' THEN 'Abril'
		 WHEN e.data_envio LIKE '%05%' THEN 'Maio'
		 WHEN e.data_envio LIKE '%06%' THEN 'Junho'
		 WHEN e.data_envio LIKE '%07%' THEN 'Julho'
		 WHEN e.data_envio LIKE '%08%' THEN 'Agosto'
		 WHEN e.data_envio LIKE '%09%' THEN 'Setembro'
		 WHEN e.data_envio LIKE '%10%' THEN 'Outubro'
		 WHEN e.data_envio LIKE '%11%' THEN 'Novembro'
		 WHEN e.data_envio LIKE '%12%' THEN 'Dezembro'
		 END AS mes_envio,
		COUNT(e.status_envio) AS soma
FROM
	envios e
INNER JOIN armazens AS a ON e.armazem_origem_id = a.armazem_id
WHERE
	status_envio = 'Atrasado'
GROUP BY
	e.data_envio,
	e.transportadora,
	a.pais
	)
	SELECT
		pais,
		transportadora,
		mes_envio,
		SUM(soma) AS atrasos
	FROM
		mes
	GROUP BY
		mes_envio,
		pais,
		transportadora
	ORDER BY
	pais,
	mes_envio DESC

