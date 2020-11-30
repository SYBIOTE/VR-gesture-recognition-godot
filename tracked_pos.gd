extends Position3D
#############################################################################
#the main Q recognizer code is here
#############################################################################
signal result_send
const NumPoints = 32;
const MaxIntCoord = 64
const LUTSize = 32
const LUTScaleFactor = MaxIntCoord / LUTSize
func make_point(vec,ID):
	var point = []
	point.resize(3)
	point[0]=vec
	point[1]=ID
	point[2]=Vector3(0,0,0)
	return point
var _name
var pts
var lut

func start_cloud(nm,pt):
	var point_cloud=[_name,pts,lut]
	point_cloud[0]=nm
	var temp_pts=resample(pt,NumPoints)
	temp_pts=_scale(temp_pts)
	temp_pts=translateto(temp_pts,make_point(Vector3(0,0,0),0))
	temp_pts=mkintcord(temp_pts)
	point_cloud[1]=temp_pts
	point_cloud[2]=complut(point_cloud[1])
	return point_cloud
func resample(p,n):
	pass
	var I = pthl(p)/(n-1)
	var D= 0.0
	var n_p=[] 
	for i in range(p.size()):
		if p[i][1] == p[i-1][1]:
			var d = p[i-1][0].distance_to(p[i][0])
			if D+d >= I:
				var qvec = p[i-1][0] + ((I-D)/d)*(p[i][0]-p[i-1][0])
				var q = make_point(qvec,p[i][1])
				n_p.append(q)
				p.insert(i,q)
				D=0.0
			else:
				D+=d
	if n_p.size() == n-1:
		n_p.append(make_point(p[p.size()-1][0],p[p.size()-1][1]))
	return n_p
func _scale(p):
	var min_vec=Vector3(INF,INF,INF)
	var max_vec=Vector3(-INF,-INF,-INF)
	for i in range(p.size()):
		min_vec.x=min(min_vec.x,p[i][0].x)
		min_vec.y=min(min_vec.y,p[i][0].y)
		min_vec.z=min(min_vec.z,p[i][0].z)
		max_vec.x=max(max_vec.x,p[i][0].x)
		max_vec.y=max(max_vec.y,p[i][0].y)
		max_vec.z=max(max_vec.z,p[i][0].z)
	var size_calc=[max_vec.x-min_vec.x,max_vec.y-min_vec.y,max_vec.z-min_vec.z]
	var size=size_calc.max()
	var n_p=[]
	for i in range(p.size()):
		var qvec
		if !size:
			qvec=Vector3(0,0,0)
		else:
			qvec= (p[i][0] - min_vec)/size
		n_p.append(make_point(qvec,p[i][1]))
	return n_p
func translateto(p,pt):
	pass
	var c = centroid(p)
	var n_p = []
	for i in range(p.size()):
		var qvec= p[i][0] + pt[0]-c[0]
		n_p.append(make_point(qvec,p[i][1]))
	return n_p
func centroid(p):
	var vec= Vector3()
	for i in range(p.size()):
		vec+=p[i][0]
	vec/=p.size()
	return make_point(vec,0)
func pthl(p):
	var d=0
	for i in range(1,p.size()):
		if p[i][1] == p[i-1][1]:
			d+=p[i-1][0].distance_to(p[i][0])
	return d 
func mkintcord(p):
	for i in range(p.size()):
		p[i][2] = (p[i][0]+Vector3(1,1,1))/2*(MaxIntCoord-1)
	return p
func complut(p):
		pass
		var _lut=[]
		_lut.resize(LUTSize)
		for i in range(LUTSize):
			_lut[i] = []
			_lut[i].resize(LUTSize)
			for j in range(LUTSize):
				_lut[i][j] = []
				_lut[i][j].resize(LUTSize)
		for x in range(LUTSize):
			for y in range(LUTSize):
				for z in range(LUTSize):
					var u = -1
					var b = INF
					for l in range(p.size()):
						var _vec = p[l][2]/LUTScaleFactor
						_vec.x = round(_vec.x)
						_vec.y = round(_vec.y)
						_vec.z = round(_vec.z)
						var d = pow(_vec.x-x,2)+pow(_vec.y-y,2)+pow(_vec.z-z,2)
						if d<b:
							b=d
							u=l
					_lut[x][y][z]=u
		return _lut

var p_c = [] # stored templates
func recognize(points):
	var candidate = start_cloud("",points)
	var u = -1
	var b = INF
	for i in range(p_c.size()):
		var d = cldmatch(candidate,p_c[i],b)
		if d<b:
			b=d
			u=i
	if u == -1:
		return ["no match",0.0]
	else:
		if b>1.0:
			b=1.0/b
		else: 
			b=1.0
		var n=p_c[u][0]
		return [n,b]
func add_gesture(nme, pts):
	p_c.append(start_cloud(nme,pts))
	var num=0
	for i in p_c:
		if i[0]==nme:
			num+=1
	return num
func delete_gesture():
	p_c.clear()
func cldmatch(candidate, template, minsof):
	var n = candidate[1].size()
	var step = floor(pow(n,.5))
	var LB1 = CLB(candidate[1],template[1],step,template[2])
	var LB2 = CLB(template[1],candidate[1],step,candidate[2])
	var i=0
	var j=0
	while i<n:
		if LB1[j]<minsof:
			minsof=min(minsof,cldd(candidate[1],template[1],i,minsof))
		if LB2[j]<minsof:
			minsof=min(minsof,cldd(template[1],candidate[1],i,minsof))
		i+=step
		j+=1
	return minsof
func cldd(a,b,start,minsof):
	var n = a.size()
	var unmatched=[]
	for j in range(n):
		unmatched.append(j)
	var i = start
	var w=n
	var sum=0.0
	while(i!=start):
		var u=-1;
		var p=INF
		for j in range(unmatched.size()):
			var d = a[i][0].distance_squared_to(b[unmatched[j]][0])
			if d<p:
				p=d
				u=j
		unmatched.remove(u)
		sum+=w*p
		if sum>=minsof:
			return sum
		w-=1
		i = (i + 1) % n
	return sum
func CLB(a,b,step,LUT):
	var n = a.size()
	var lb = []
	lb.resize(floor(n / step) + 1)
	var sat = []
	sat.resize(n)
	lb[0] = 0.0
	for i in range(n):
		var vec =a[i][2]/LUTScaleFactor
		vec.x= round(vec.x)
		vec.y= round(vec.y)
		vec.z= round(vec.z)
		var idx = LUT[vec.x][vec.y][vec.z]
		var d = a[i][0].distance_squared_to(b[idx][0])
		if i == 0:
			sat[i] = d 
		else:
			sat[i] = sat[i - 1]+d
		lb[0] += (n-i)*d
	var i = step
	var j = 1
	while i<n:
		lb[j] = lb[0] + i * sat[n-1] -n * sat[i-1]
		i+=step
		j+=1
	return lb
#############################################################################
#the interface starts here
#############################################################################
# tracked pos should always be a direct child of an ARVR contoller node
# trigger button pressed tarts tracking, release stops tracking 
# when u press trigger your points get stored into an array , 
# sent to recognizer
# ________________________________
# if u press add template
# when u press trigger your points get stored into an array , 
# are made into points
# sent to add template
#_________________________________
# delete template deletes all templates
enum ACTION{
	RECOGNIZE,
	ADD,
	IDLE
}
var action=["recognize","add","idle"]
var track_button = vr.CONTROLLER_BUTTON.INDEX_TRIGGER
var set_button = vr.CONTROLLER_BUTTON.INDEX_TRIGGER
var user_state=ACTION.IDLE
var add_name
var controller : ARVRController = null;
var add_mode=false
var point_array=[]
func display_templates():
	pass
	for i in p_c:
		vr.log_info(i[0])
	# shows names of the avaiable/added templates
func _ready():
	controller = get_parent();
	#gets parent as ARVR contoller and sets it to controller needed for button press recong
	# can be modified 
func _physics_process(delta):
	var info = get_parent().get_parent().get_parent().get_node("OQ_UILabel")
	var click = controller._button_pressed(track_button)
	var release = controller._button_just_released(set_button)
	info.set_label_text("state =" + "\n add mode ="  + str(add_mode) + "\n" + action[user_state] + "\n click =" +str(click) + " \n release = " + str(release))
	var id_count=0
	if Input.is_action_just_pressed("add_mode"):
		add_mode=true
		add_name="type " + str(id_count)
		id_count+=1
	match user_state:
		ACTION.IDLE:
			if click:
				if add_mode:
					user_state=ACTION.ADD
				else:
					user_state=ACTION.RECOGNIZE
		ACTION.RECOGNIZE:
			point_array.append(make_point(global_transform.origin,controller.controller_id))
			if !click:
				var result=recognize(point_array)
				display_templates()
				vr.log_info("result"+str(result[0])+" score "+str(result[1]))
				get_parent().get_parent().get_parent().result(str(result[0]))
				point_array.clear()
				user_state=ACTION.IDLE
				#stop tracking ,recogize pool
		ACTION.ADD:
			point_array.append(make_point(global_transform.origin,controller.controller_id))
			info.set_label_text("state =" + "\n add mode =" +  "\n" + str(add_mode)+ action[user_state] + "\n click =" +str(click) + " \n release = " + str(release))
			if !click:
				vr.log_info(" add_name = "+ add_name)
				add_gesture(add_name,point_array)
				display_templates()
				point_array.clear()
				user_state=ACTION.IDLE
				add_mode=false
				add_name=null
