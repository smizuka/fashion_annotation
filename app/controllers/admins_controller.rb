class AdminsController < ApplicationController

  #progressのページ
  def progress
    users = User.all

    @progress=[]
    for user in users

      #ユーザーに紐付いたallocationを取得
      allo = Allocation.where(user_id: user.id)
      total = allo.count

      #totalが０だったら、次のユーザーへ
      if total == 0
        next
      end

      #重複しないフォルダ名を取得する
      folderes = allo.map {|i| i.folder }.uniq

      #フォルダを１つずつ取り出して、作業中のものと作業済みのものを分ける
      work_states=[]
      for folder in folderes
        #終了したもの
        finish = allo.select{|n| n.folder == folder && n.state == "end"}.count
        #作業中のもの
        working = allo.select{|n| n.folder == folder && n.state == "working"}.count
        #進捗
        rate = ((finish.to_f / (finish.to_f + working.to_f))*100).ceil
        work_states.push([folder, rate, finish, (finish + working)])
      end

      if user.user_type=="inhouse"
        user_type = "社内"
      else
        user_type = "社外"
      end

      #作業済みのデータ数と全体数を割って、進捗率を計算する
      @progress.push([user.name, user.login_id, user_type, work_states])
    end

  end

  #作業進捗のページ
  #@usersを渡す
  def preprocess
    users = User.all
    #userのidと名前だけを抽出する
    @users =[]
    for user in users

      if user.user_type=="inhouse"
        user_type = "社内"
      else
        user_type = "社外"
      end

      if user.user_type != "admin"
        content = {id: user.id, name: user.name, login_id: user.login_id, type: user_type, display_id: user.display_id}
        @users.push(content)
      end
    end
  end

  #メインのページ
  def main

    users = User.all

    #アノテーション画像の一覧を取得
    annotations = Annotation.all

    #重複しないフォルダリストを取得する
    folder_list = annotations.map {|i| i.folder_name }.uniq

    allo = Allocation.all
    #各フォルダに存在する画像数を取得する

    file_num =[]
    for folder in folder_list
       num = annotations.select{|i| i.folder_name == folder }.count
       file_num.push(num)
    end

     #フォルダ名とファイル数のペアを取得
    @contents = []
    folder_list.zip(file_num) do |f, n|
        user_state=[]
        user_name=[]
        for user in users
          if user.user_type != "admin" && user.display_id == "display"
            #その作業者に割り当てられている場合はカウントが正の数になる。
            num = allo.select{|i| i.folder == f && i.user_id == user.id}.count
            user_state.push([user.id, user.name, num])

            #作業者に割り当てがされている場合はuser_nameに値を入れる
            if num != 0
              user_name.push(user.name)
            end
          end
        end

        # user_name = user_state.select{|i| i.num != 0 }.count

        #[ファイルリスト、各フォルダの中にあるファイルの枚数、各ユーザーの状態を示した配列、]
        @contents.push([f, n, user_state,user_name])
    end

  end

  def add_file
    folder_names = Annotation.select(:folder_name).distinct
    folder_names =folder_names.map{ |i| i["folder_name"] }

    folder_name = params[:file].original_filename

    if folder_names.include?(folder_name[0..-5])
        redirect_to admins_main_path, info: '同じフォルダ名が存在します'
    else
        Annotation.import(params[:file])
        redirect_to admins_main_path, success: '登録しました'
    end
  end

  def create_allocation

    data = params["format"].split("/")
    annotations = Annotation.where(folder_name: data[1])

    #割り当てした人数
    # num = Allocation.where(folder: data[1]).map {|i| i.user_id }.uniq.count
    users1 = Allocation.where(folder: data[1]).map {|i| i.user_id }.uniq
    users2 = User.where(display_id: "display").map{ |i| i.id }

    num = users1.select{ |i| users2.include?(i) }.count

    if num == 3
      redirect_to admins_main_path, info: '割り当ては３人までです。'
    else
      for annotation in annotations
        allocation = Allocation.new
        allocation.user_id = data[0].to_i
        allocation.annotation_id = annotation.id
        allocation.folder = data[1]
        allocation.state = 0
        allocation.save
      end
      redirect_to admins_main_path, success: '割り当てました'
    end

  end

   #DBをCSV出力するときの動作
  def send_posts_csv(posts, file_name)
    require "csv"
    csv_data = CSV.generate do |csv|
      # header = %w(id user_name folder_name path information)
      header = %w(id path information)
      csv << header

      posts.each do |post|
        csv << post
      end

    end
    send_data(csv_data, filename: file_name)
  end

  #すべてのCSVデータを出力する
  def post
    #admin以外のユーザーを取得する
    users = User.where.not(user_type: "admin")

    @edited =[]
    for user in users
      # edited_data = user.edited_annotations
      editeds = Edited.where(user_id: user.id)

      editeds.each do | edited |
        @edited.push([user.login_id, edited.path, edited.information])
      end
    end

    #生データ
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv(@edited, "posts.csv")
      end
    end

  end

  #登録したファイルを削除する
  def destroyFile
    deleteFiles = Annotation.where(folder_name: params["format"])

    for deleteFile in deleteFiles
      deleteFile.destroy
    end

    deleteAllocations = Allocation.where(folder: params["format"])

    for deleteAllocation in deleteAllocations
      deleteAllocation.destroy
    end

    redirect_to admins_main_path, success: 'ファイルを削除しました'
  end

  #割り当てしたユーザーを削除する
  def destroyUser
    user_id = params["format"].to_i

    #該当のUser_idとstate:0になるものを選ぶ
    # allocations = Allocation.where(user_id: user_id, state: "working")
    allocations = Allocation.where(user_id: user_id)
    # binding.pry

    if allocations.count == 0
      redirect_to admins_main_path, info: '該当するユーザーはいません'
    else
      for allocation in allocations
        allocation.destroy
      end
      redirect_to admins_main_path, success: '割り当てしたユーザーを削除しました'
    end
  end

  def display

    user = User.find(params["format"].to_i)
    user.update_attribute(:display_id, "display")

    redirect_to admins_preprocess_path, success: 'ユーザーを表示しました。'
  end

  def hidden
    user = User.find(params["format"].to_i)
    user.update_attribute(:display_id, "block")

    @users = params[0]
    @contents = params[1]
    @progress = params[2]

    redirect_to admins_preprocess_path, success: 'ユーザーを非表示にしました。'
  end

  #平均を算出する
  def avg
    users = User.where.not(user_type: "admin")

    @edited =[]
    for user in users
      # edited_data = user.edited_annotations
      editeds = Edited.where(user_id: user.id)

      for edited in editeds
        @edited.push([user.login_id, edited.annotation_id, edited.path, edited.information])
      end
    end

    #annotation_idだけを取り出す
    annotation_id_lists = @edited.map{ |i| i[1] }
    #annotation_idの重複をなくしたリスト
    annotation_id_lists = annotation_id_lists.uniq

    #作業済みの画像だけをとってくる
    # anno = Allocation.where(state: "end")

    #作業済みがアノテーション画像のidを取得する
    # anno_id = []
    # for a in anno
    #   anno_id.push(a.annotation_id)
    # end

    annotations=[]
    for a in annotation_id_lists
      #同じアノテーション画像が複数ある場合、それらをすべて取得する
      annotation = @edited.select{|i| i[1] == a }

      if annotation.count != 0
        annotations.push(annotation)
      end
    end

    @average =[]
    for annotation in annotations
      #その画像をアノテーションした作業者
      users=[]
      #鳥画像の位置座標
      x1 = 0
      y1 = 0
      w1 = 0
      h1 = 0
      #画像の種別を表す記号
      var = []

      for a in annotation
        users.push(a[0])
        content = a[3].split(",")
        x1 += content[0].to_i
        y1 += content[1].to_i
        w1 += content[2].to_i
        h1 += content[3].to_i
        var.push(content[4])
      end

      #画像の種別の中で最も多いものを抽出
      var.group_by { |e| e }.sort_by { |e, v| -v.size }.map(&:first).first
      anno_num = annotation.count
      info = [(x1/anno_num).to_i,(y1/anno_num).to_i,(w1/anno_num).to_i,(h1/anno_num).to_i,var[0]]
      info = info.join(",")
      users = users.join(",")

      #annotation_id,
      # avg = [annotation[0][0], users, annotation[0][2], annotation[0][3], info]
      avg = [users, annotation[0][2], info]

      @average.push(avg)
    end

    #平均計算
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv(@average, "average.csv")
      end
    end
  end

end
