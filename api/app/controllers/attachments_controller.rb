# frozen_string_literal: true

class AttachmentsController < ApplicationController
  before_action :require_login
  before_action :reject_audience, :validate_file, only: :create

  def show
    # tokenを知っているなら誰でも取得可能
    attachment = Attachment.find_by(token: params[:id])

    if attachment.nil?
      render json: "attachment(#{params[:id]}) not found", status: :not_found
      return
    end

    # filenameには間違えて問題コードを含んでしまうことが多いので代わりにtokenを返す
    send_data(
      attachment.data,
      filename: attachment.token + File.extname(attachment.filename),
      type: attachment.content_type,
      disposition: 'inline',
      stream: 'true',
      buffer_size: '4096'
    )
  end

  def create
    attachment = Attachment.new(
      filename: file.original_filename,
      data: file.read,
      content_type: file.content_type,
      size: file.size,
      team: current_team
    )

    if attachment.save
      render json: attachment_path(attachment.token), status: :ok
    else
      Rails.logger.error attachment.errors.full_messages
      render json: attachment.errors.messages, status: :bad_request
    end
  end

  private

  def file
    params.permit(:file)[:file]
  end

  def validate_file
    if file.blank?
      render json: '"file" field is required', status: :bad_request
    elsif !file.is_a?(ActionDispatch::Http::UploadedFile)
      render json: '"file" field accept only file', status: :bad_request
    elsif current_team.player? && 20.megabyte < file.size
      # サイズ制限(適当)
      render json: 'file size must be 20MB or less', status: :bad_request
    end
  end
end
