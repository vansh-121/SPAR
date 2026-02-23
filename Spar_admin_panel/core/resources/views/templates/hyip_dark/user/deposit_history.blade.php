@extends($activeTemplate . 'layouts.master')

@section('content')
    <div class="row gy-4">
        <div class="col-md-12">
            <form>
                <div class="d-flex justify-content-end table-search">
                    <div class="input-group">
                        <input type="text" name="search" class="form--control form-control form-two" value="{{ request()->search }}" placeholder="@lang('Search by transactions')">
                        <button class="input-group-text input-style">
                            <i class="las la-search"></i>
                        </button>
                    </div>
                </div>
            </form>
        </div>
        <div class="col-md-12">
            <div class="card custom--card">
                <div class="card-body">
                    <table class="table table--responsive--xl">
                        <thead>
                            <tr>
                                <th>@lang('Gateway | Transaction')</th>
                                <th>@lang('Initiated')</th>
                                <th>@lang('Amount')</th>
                                <th>@lang('Conversion')</th>
                                <th>@lang('Status')</th>
                                <th>@lang('Details')</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($deposits as $deposit)
                                <tr>
                                    <td>
                                        <div>
                                            <span class="fw-bold"> <span>{{ __($deposit->gateway?->name) }}</span> </span>
                                            <br>
                                            <small> {{ $deposit->trx }} </small>
                                        </div>
                                    </td>

                                    <td>
                                        <div>
                                            {{ showDateTime($deposit->created_at) }}<br>{{ diffForHumans($deposit->created_at) }}
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            {{ showAmount($deposit->amount) }} + <span class="text-danger" title="@lang('charge')">{{ showAmount($deposit->charge) }} </span>
                                            <br>
                                            <strong title="@lang('Amount with charge')">
                                                {{ showAmount($deposit->amount + $deposit->charge) }}
                                            </strong>
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            1 {{ __(gs('cur_text')) }} = {{ showAmount($deposit->rate, currencyFormat: false) }} {{ __($deposit->method_currency) }}
                                            <br>
                                            <strong>{{ showAmount($deposit->final_amount, currencyFormat: false) }} {{ __($deposit->method_currency) }}</strong>
                                        </div>
                                    </td>
                                    <td>
                                        @php echo $deposit->statusBadge @endphp
                                    </td>
                                    @php
                                        $details = [];
                                        if ($deposit->method_code >= 1000 && $deposit->method_code <= 5000) {
                                            foreach (@$deposit->detail ?? [] as $key => $info) {
                                                $details[] = $info;
                                                if ($info->type == 'file') {
                                                    $details[$key]->value = route('user.download.attachment', encrypt(getFilePath('verify') . '/' . $info->value));
                                                }
                                            }
                                        }
                                    @endphp

                                    <td>
                                        <div class="action--btns">
                                            @if ($deposit->method_code >= 1000 && $deposit->method_code <= 5000)
                                                <a href="javascript:void(0)" class="icon-btn bg--base text-white detailBtn"  data-info="{{ json_encode($details) }}" @if ($deposit->status == Status::PAYMENT_REJECT) data-admin_feedback="{{ $deposit->admin_feedback }}" @endif>
                                                    <i class="fas fa-desktop"></i>
                                                </a>
                                            @else
                                                <button type="button" class="icon-btn bg--base text-white" data-bs-toggle="tooltip" title="@lang('Automatically processed')">
                                                    <i class="fas fa-check"></i>
                                                </button>
                                            @endif
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="100%" class="text-center">{{ __($emptyMessage) }}</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            {{ paginateLinks($deposits) }}
        </div>
    </div>

    {{-- APPROVE MODAL --}}
    <div id="detailModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title">@lang('Details')</h6>
                    <button type="button" class="close" data-bs-dismiss="modal">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <ul class="list--group userData mb-2">
                    </ul>
                    <div class="feedback"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn--danger" data-bs-dismiss="modal">@lang('Close')</button>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script')
    <script>
        (function($) {
            "use strict";
            $('.detailBtn').on('click', function() {
                var modal = $('#detailModal');

                var userData = $(this).data('info');
                var html = '';
                if (userData) {
                    userData.forEach(element => {
                        if (element.type != 'file') {
                            html += `
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                <span>${element.name}</span>
                                <span">${element.value}</span>
                            </li>`;
                        }
                    });
                }

                modal.find('.userData').html(html);

                if ($(this).data('admin_feedback') != undefined) {
                    var adminFeedback = `
                        <div class="my-3">
                            <strong>@lang('Admin Feedback')</strong>
                            <p>${$(this).data('admin_feedback')}</p>
                        </div>
                    `;
                } else {
                    var adminFeedback = '';
                }

                modal.find('.feedback').html(adminFeedback);


                modal.modal('show');
            });
        })(jQuery);
    </script>
@endpush
