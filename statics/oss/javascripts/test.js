var _ = require('undersocre');
var doing = {}

var wrapChangeStock = fucntion(p_kbn, p_shop_id, p_product_id, p_ab_flg, p_count, p_modified_id, cbf){
	// 生成标识query的key
	var args = _.toArray(arguments);
	args.pop();
	var key = se(args);
	
	if(doing[key]){
		// 如果有相同的操作正在进行，则添加到回调函数数组中
		doing[key].push(cbf);
	}else{
		// 没有相同的操作在进行，则调用你写的函数
		change_stock(/*我这里前面的参数省略*/, function(err, result){
			cbf(err, result);
			// 对之前保存的回调循环调用一次
			_.each(doing[key], function(cbf){
				cbf(err, result);
			});
			delete doing[key];
		});
		// 根据这个操作的key，创建一个数组用于保存当操作未完成时，后面又进来的操作回调
		doing[key] = [];
	}

};

var se = function(args){
	return args.join('_');
};

var change_stock = function(p_kbn, p_shop_id, p_product_id, p_ab_flg, p_count, p_modified_id, cbf) {
	// .......
	// ......
};
